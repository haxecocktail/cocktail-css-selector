/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package cocktail.selector;

import cocktail.selector.SelectorData;
import cocktail.selector.matchers.Attributes;

/**
 * Interface for a MatchableElement, which will typically
 * be a DOM node.
 * Using this abstraction allows for not depend on DOM projects
 */
interface IMatchableElement<Element:IMatchableElement<Element, ClassList>, ClassList:IClassList>
{
    function getAttribute(name:String):String;
    function hasChildNodes():Bool;
    var tagName:String;
    var previousElementSibling:Element;
    var nextElementSibling:Element;
    var parentElement:Element;
    var id:String;
    var childNodes:Array<Element>;
    var classList:ClassList;
}

/**
 * Interface for a type able to determine wheter it contains a value,
 * which will typically be a DOMTokenList
 */
interface IClassList
{
    function contains(name:String):Bool;
}

/**
 * The selector matcher has 2 purposes : 
 * - For a given element and selector, it returns wether the element
 * matches the selector
 * - For a given selector, it can return its specificity (its priority)
 *     
 * @author Yannick DOMINGUEZ
 */
class SelectorMatcher<MatchableElement:IMatchableElement<MatchableElement, ClassList>, ClassList:IClassList>
{
    /**
     * <html> tag name
     */
    private static inline var HTML_HTML_TAG_NAME:String = "HTML";


    /**
     * identifier for node of type element
     */
    private static inline var ELEMENT_NODE:Int = 1;

    /**
     * Used to count the current selector specifity.
     * Implemented as class attribute to only 
     * instantiate one
     */
    private var _selectorSpecificityVO:SelectorSpecificityVO;
    
    /**
     * class constructor
     */
    public function new() 
    {
        _selectorSpecificityVO = new SelectorSpecificityVO();
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // PUBLIC SELECTOR MATCHING METHODS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * For a given element and selector, return wether
     * the element matches all of the components of the selector
     */
    public function match(element:MatchableElement, selector:SelectorVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var components:Array<SelectorComponentValue> = selector.components;
        
        //a flag set to true when the last item in the components array
        //was a combinator.
        //This flag is a shortcut to prevent matching again selector
        //sequence that were matched by the combinator
        var lastWasCombinator:Bool = false;
        
        //loop in all the components of the selector
        var length:Int = components.length;
        for (i in 0...length)
        {
            var component:SelectorComponentValue = components[i];
    
            //wether the current selector component match the element
            var matched:Bool = false;
            
            switch(component)
            {
                case SelectorComponentValue.COMBINATOR(value):
                    matched = matchCombinator(element, value, components[i + 1], matchedPseudoClasses);
                    lastWasCombinator = true;
                    
                    //if the combinator is a child combinator, the relevant
                    //element becomes the parent element as any subsequent would
                    //apply to it instead of the current element
                    if (value == CHILD)
                    {
                        element = element.parentElement;
                    }
                    
                case SelectorComponentValue.SIMPLE_SELECTOR_SEQUENCE(value):
                    //if the previous item was a combinator, then 
                    //this simple selector sequence was already
                    //successfuly matched, else the method would have
                    //returned
                    if (lastWasCombinator == true) 
                    {
                        matched = true;
                        lastWasCombinator = false;
                    }
                    else
                    {
                        matched = matchSimpleSelectorSequence(element, value, matchedPseudoClasses);
                    }
            }
            
            //if the component is not
            //matched, then the selector is not matched
            if (matched == false)
            {
                return false;
            }
        }
        
        return true;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // PRIVATE SELECTOR MATCHING METHODS
    //////////////////////////////////////////////////////////////////////////////////////////
    
        // COMBINATORS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * return wether a combinator is matched
     */
    private function matchCombinator(element:MatchableElement, combinator:CombinatorValue, nextSelectorComponent:SelectorComponentValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        //if the element has no parent, it can't match
        //any combinator
        if (element.parentElement == null)
        {
            return false;
        }
        
        var nextSelectorSequence:SimpleSelectorSequenceVO = null;
        //the next component at this point is always a simple
        //selector sequence, there can't be 2 combinators in a row
        //in a selector, it makes the selector invalid
        switch(nextSelectorComponent)
        {
            case SIMPLE_SELECTOR_SEQUENCE(value):
                nextSelectorSequence = value;
                
            case COMBINATOR(value):    
                return false;
        }
        
        switch(combinator)
        {
            case CombinatorValue.ADJACENT_SIBLING:
                return matchAdjacentSiblingCombinator(element, nextSelectorSequence, matchedPseudoClasses);
                
            case CombinatorValue.GENERAL_SIBLING:
                return matchGeneralSiblingCombinator(element, nextSelectorSequence, matchedPseudoClasses);
                
            case CombinatorValue.CHILD:
                return matchChildCombinator(element, nextSelectorSequence, matchedPseudoClasses);
                
            case CombinatorValue.DESCENDANT:
                return matchDescendantCombinator(element, nextSelectorSequence, matchedPseudoClasses);
        }
    }
    
    /**
     * Return wether a general sibling combinator is
     * matched.
     * 
     * It is matched if the element has a sibling matching
     * the preious selector sequence which precedes in 
     * the DOM tree
     */
    private function matchGeneralSiblingCombinator(element:MatchableElement, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var previousElementSibling:MatchableElement = element.previousElementSibling;
        
        while (previousElementSibling != null)
        {
            if (matchSimpleSelectorSequence(previousElementSibling, nextSelectorSequence, matchedPseudoClasses) == true)
            {
                return true;
            }
            
            previousElementSibling = previousElementSibling.previousElementSibling;
        }
        
        return false;
    }
    
    /**
     * Same as general sibling combinator, but 
     * only matched if the first previous
     * element sibling of the element matches
     * the previous selector
     */
    private function  matchAdjacentSiblingCombinator(element:MatchableElement, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var previousElementSibling:MatchableElement = element.previousElementSibling;
        
        if (previousElementSibling == null)
        {
            return false;
        }
        
        return matchSimpleSelectorSequence(previousElementSibling, nextSelectorSequence, matchedPseudoClasses);
    }
    
    /**
     * Return wether a descendant combinator is matched.
     * It is matched when an ancestor of the element
     * matches the next selector sequence
     */
    private function matchDescendantCombinator(element:MatchableElement, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var parentElement:MatchableElement = element.parentElement;
        
        //check that at least one ancestor matches
        //the parent selector
        while (parentElement != null)
        {
            if (matchSimpleSelectorSequence(parentElement, nextSelectorSequence, matchedPseudoClasses) == true)
            {
                return true;
            }
            
            parentElement = parentElement.parentElement;
        }
        
        //here no parent matched, so the
        //combinator is not matched
        return false;
    }
    
    /**
     * Same as matchDescendantCombinator, but the 
     * next selector sequence must be matched by the 
     * direct parent of the element and not just any ancestor
     */
    private function matchChildCombinator(element:MatchableElement, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        return matchSimpleSelectorSequence(element.parentElement, nextSelectorSequence, matchedPseudoClasses);
    }
    
        // SIMPLE SELECTORS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * Return wether a element match a simple selector sequence starter.
     * 
     * A simple selector sequence is a list of simple selector, 
     * for instance in : div.myclass , div is a simple selector, .myclass is too 
     * and together they are a simple selector sequence
     * 
     * A simple selector sequence always start with either a type (like 'div') or a universal ('*')
     * selector
     */
    private function matchSimpleSelectorSequenceStart(element:MatchableElement, simpleSelectorSequenceStart:SimpleSelectorSequenceStartValue):Bool
    {
        switch(simpleSelectorSequenceStart)
        {
            case SimpleSelectorSequenceStartValue.TYPE(value):
                return element.tagName == value;
                
            case SimpleSelectorSequenceStartValue.UNIVERSAL:
                return true;
        }
    }
    
    /**
     * Return weher a element match an item of a simple selector sequence.
     * The possible items of a simple selector are all simple selectors
     * (class, ID...) but type or universal which are always at the 
     * begining of a simple selector sequence
     */
    private function matchSimpleSelectorSequenceItem(element:MatchableElement, simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch(simpleSelectorSequenceItem)
        {
            //for this check the list of class of the element    
            case CSS_CLASS(value):
                var classList:ClassList = element.classList;
                
                //here the element has no classes
                if (classList == null)
                { 
                    return false;
                }
                
                return classList.contains(value);
                
            //for this check the id attribute of the element    
            case ID(value):
                return element.id == value;    
                
            case PSEUDO_CLASS(value):
                return matchPseudoClassSelector(element, value, matchedPseudoClasses);    
            
            case ATTRIBUTE(value):
                return Attributes.match(element.getAttribute, value);
        }        
    }
    
    /**
     * Return wether all items in a simple selector
     * sequence are matched
     */
    private function matchSimpleSelectorSequence(element:MatchableElement, simpleSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        //check if sequence start matches
        if (matchSimpleSelectorSequenceStart(element, simpleSelectorSequence.startValue) == false)
        {
            return false;
        }
        
        //check all items
        var simpleSelectors:Array<SimpleSelectorSequenceItemValue> =  simpleSelectorSequence.simpleSelectors;
        var length:Int = simpleSelectors.length;
        for (i in 0...length)
        {
            var simpleSelectorSequence:SimpleSelectorSequenceItemValue = simpleSelectors[i];
            if (matchSimpleSelectorSequenceItem(element, simpleSelectorSequence, matchedPseudoClasses) == false)
            {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Return wether a pseudo class matches
     * the element
     */
    private function matchPseudoClassSelector(element:MatchableElement, pseudoClassSelector:PseudoClassSelectorValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch (pseudoClassSelector)
        {
            case PseudoClassSelectorValue.STRUCTURAL(value):
                return matchStructuralPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.LINK(value):
                return matchLinkPseudoClassSelector(element, value, matchedPseudoClasses);
                
            case PseudoClassSelectorValue.USER_ACTION(value):
                return matchUserActionPseudoClassSelector(element, value, matchedPseudoClasses);    
                
            case PseudoClassSelectorValue.TARGET:
                return matchTargetPseudoClassSelector(element);
                
            case PseudoClassSelectorValue.NOT(value):
                return matchNegationPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.LANG(value):
                return matchLangPseudoClassSelector(element, value);
                
            case PseudoClassSelectorValue.UI_ELEMENT_STATES(value):
                return matchUIElementStatesSelector(element, value, matchedPseudoClasses);

            case PseudoClassSelectorValue.FULLSCREEN:
                return matchedPseudoClasses.fullscreen;
            
            default:
                return false;
        }
    }
    
    /**
     * Return wether a UI state selector
     * matches the element
     */
    private function matchUIElementStatesSelector(element:MatchableElement, uiElementState:UIElementStatesValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch(uiElementState)
        {
            case UIElementStatesValue.CHECKED:
                return matchedPseudoClasses.checked;
                
            case UIElementStatesValue.DISABLED:
                return matchedPseudoClasses.disabled;
                
            case UIElementStatesValue.ENABLED:
                return matchedPseudoClasses.enabled;
        }
    }
    
    /**
     * Return wether a negation pseudo-class selector
     * matches the element
     */
    private function matchNegationPseudoClassSelector(element:MatchableElement, negationSimpleSelectorSequence:SimpleSelectorSequenceVO):Bool
    {
        return false;
    }

    /**
     * Return wether a lang pseudo-class selector
     * matches the element
     */
    private function matchLangPseudoClassSelector(element:MatchableElement, lang:Array<String>):Bool
    {
        return false;
    }
    
    /**
     * Return wether a structural pseudo-class selector
     * matches the element
     */
    private function matchStructuralPseudoClassSelector(element:MatchableElement, structuralPseudoClassSelector:StructuralPseudoClassSelectorValue):Bool
    {
        switch(structuralPseudoClassSelector)
        {
            case StructuralPseudoClassSelectorValue.EMPTY:
                return element.hasChildNodes();
                
            case StructuralPseudoClassSelectorValue.FIRST_CHILD:
                
                //HTML root element is not considered a first child
                //
                //TODO : parent of root element should actually be a document
                if (element.parentElement == null)
                {
                    return false;
                }
                
                return element.previousElementSibling == null;
                
            case StructuralPseudoClassSelectorValue.LAST_CHILD:
                
                //HTML root element not considered last child
                if (element.parentElement == null)
                {
                    return false;
                }
                
                return element.nextElementSibling == null;
                
            case StructuralPseudoClassSelectorValue.ONLY_CHILD:
                
                //HTML root element is not considered only child
                if (element.parentElement == null)
                {
                    return false;
                }
                
                return element.parentElement.childNodes.length == 1;
                
            case StructuralPseudoClassSelectorValue.ROOT:
                return element.tagName == HTML_HTML_TAG_NAME && element.parentElement == null;
                
            case StructuralPseudoClassSelectorValue.ONLY_OF_TYPE:
                return matchOnlyOfType(element);
                
            case StructuralPseudoClassSelectorValue.FIRST_OF_TYPE:
                return matchFirstOfType(element);
                
            case StructuralPseudoClassSelectorValue.LAST_OF_TYPE:
                return matchLastOfType(element);    
                
            case StructuralPseudoClassSelectorValue.NTH_CHILD(value):
                return matchNthChild(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_LAST_CHILD(value):
                return matchNthLastChild(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_LAST_OF_TYPE(value):
                return matchNthLastOfType(element, value);
                
            case StructuralPseudoClassSelectorValue.NTH_OF_TYPE(value):
                return matchNthOfType(element, value);
        }
    }
    
    private function matchNthChild(element:MatchableElement, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    private function matchNthLastChild(element:MatchableElement, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    private function matchNthLastOfType(element:MatchableElement, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    private function matchNthOfType(element:MatchableElement, value:StructuralPseudoClassArgumentValue):Bool
    {
        return false;
    }
    
    /**
     * Return wether the element is the first 
     * element among its element siblings of
     * its type (tag name)
     */
    private function matchFirstOfType(element:MatchableElement):Bool
    {
        var type:String = element.tagName;
        
        var previousElementSibling:MatchableElement = element.previousElementSibling;
        
        while (previousElementSibling != null)
        {
            if (previousElementSibling.tagName == type)
            {
                return false;
            }
            
            previousElementSibling = previousElementSibling.previousElementSibling;
        }
        
        return true;
    }
    
    /**
     * Same as above but for last element
     */
    private function matchLastOfType(element:MatchableElement):Bool
    {
        var type:String = element.tagName;
        
        var nextElementSibling:MatchableElement = element.nextElementSibling;
        
        while (nextElementSibling != null)
        {
            if (nextElementSibling.tagName == type)
            {
                return false;
            }
            
            nextElementSibling = nextElementSibling.nextElementSibling;
        }
        
        return true;
    }
    
    /**
     * Return wether this element is the only among
     * its element sibling of its type (tag name)
     */
    private function matchOnlyOfType(element:MatchableElement):Bool
    {
        //to be the only of its type is the same as
        //being the first and last of its type
        return matchLastOfType(element) == true && matchFirstOfType(element) == true;
    }
    
    /**
     * Return wether a link pseudo-class selector
     * matches the element
     */
    private function matchLinkPseudoClassSelector(element:MatchableElement, linkPseudoClassSelector:LinkPseudoClassValue, matchedPseudoClass:MatchedPseudoClassesVO):Bool
    {
        switch(linkPseudoClassSelector)
        {
            case LinkPseudoClassValue.LINK:
                return matchedPseudoClass.link;
                
            case LinkPseudoClassValue.VISITED:
                return false;
        }
    }
    
    /**
     * Return wether a user pseudo-class selector
     * matches the element
     */
    private function matchUserActionPseudoClassSelector(element:MatchableElement, userActionPseudoClassSelector:UserActionPseudoClassValue, matchedPseudoClass:MatchedPseudoClassesVO):Bool
    {
        switch(userActionPseudoClassSelector)
        {
            case UserActionPseudoClassValue.ACTIVE:
                return matchedPseudoClass.active;
                
            case UserActionPseudoClassValue.HOVER:
                return matchedPseudoClass.hover;
                
            case UserActionPseudoClassValue.FOCUS:
                return matchedPseudoClass.focus;
        }
    }
    
    /**
     * Return wether the target pseudo-class 
     * matches the element.
     */
    private function matchTargetPseudoClassSelector(element:MatchableElement):Bool
    {
        return false;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // PUBLIC SELECTOR SPECIFICITY METHODS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * Return the specifity of a selector, which is
     * its priority next to other selector
     */
    public function getSelectorSpecifity(selector:SelectorVO):Int
    {
        //holds the specificity data, is passed by reference
        //to all methods which can increment the specificity
        //attribute
        //reset before usage
        _selectorSpecificityVO.classAttributesAndPseudoClassesNumber = 0;
        _selectorSpecificityVO.idSelectorsNumber = 0;
        _selectorSpecificityVO.typeAndPseudoElementsNumber = 0;
        
        //a pseudo element increment the specificity
        switch (selector.pseudoElement)
        {
            case PseudoElementSelectorValue.FIRST_LETTER,
            PseudoElementSelectorValue.FIRST_LINE,
            PseudoElementSelectorValue.AFTER,
            PseudoElementSelectorValue.BEFORE:
                _selectorSpecificityVO.typeAndPseudoElementsNumber++;
            
            case PseudoElementSelectorValue.NONE:    
        }
        
        var components:Array<SelectorComponentValue> = selector.components;
        var length:Int = components.length;
        for (i in 0...length)
        {
            var component:SelectorComponentValue = components[i];
            
            switch(component)
            {
                case SelectorComponentValue.COMBINATOR(value):
                    
                case SelectorComponentValue.SIMPLE_SELECTOR_SEQUENCE(value):
                    getSimpleSelectorSequenceSpecificity(value, _selectorSpecificityVO);
            }
        }
        
        //specificity has 3 categories, whose int values are concatenated
        //for instance, if idSelectorsNumber is equal to 1, classAttributesAndPseudoClassesNumber to 0
        //and typeAndPseudoElementsNumber to 2,
        //the specificity is 102
        return _selectorSpecificityVO.idSelectorsNumber * 100 + _selectorSpecificityVO.classAttributesAndPseudoClassesNumber * 10 + _selectorSpecificityVO.typeAndPseudoElementsNumber;
    }
    
    /**
     * Increment the specificity of simple selector sequence
     */
    private function getSimpleSelectorSequenceSpecificity(simpleSelectorSequence:SimpleSelectorSequenceVO, selectorSpecificity:SelectorSpecificityVO):Void
    {
        getSimpleSelectorSequenceStartSpecificity(simpleSelectorSequence.startValue, selectorSpecificity);
        
        var simpleSelectors:Array<SimpleSelectorSequenceItemValue> = simpleSelectorSequence.simpleSelectors;
        var length:Int = simpleSelectors.length;
        for (i in 0...length)
        {
            var simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue = simpleSelectors[i];
            getSimpleSelectorSequenceItemSpecificity(simpleSelectorSequenceItem, selectorSpecificity);
        }
    }
    
    /**
     * Increment specificity according to a simple selector start item
     */
    private function getSimpleSelectorSequenceStartSpecificity(simpleSelectorSequenceStart:SimpleSelectorSequenceStartValue, selectorSpecificity:SelectorSpecificityVO):Void
    {
        switch(simpleSelectorSequenceStart)
        {
            case SimpleSelectorSequenceStartValue.TYPE(value):
                selectorSpecificity.typeAndPseudoElementsNumber++;
                
            case SimpleSelectorSequenceStartValue.UNIVERSAL:
        }
    }
    
    /**
     * Increment specificity according to a simple selector item
     */
    private function getSimpleSelectorSequenceItemSpecificity(simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue, selectorSpecificity:SelectorSpecificityVO):Void
    {
        switch (simpleSelectorSequenceItem)
        {
            case ATTRIBUTE(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case PSEUDO_CLASS(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case CSS_CLASS(value):
                selectorSpecificity.classAttributesAndPseudoClassesNumber++;
                
            case ID(value):
                selectorSpecificity.idSelectorsNumber++;
        }
    }
}
