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
import cocktail.selector.matchers.PseudoClass;
import cocktail.dom.Element;
import cocktail.dom.DOMConstants;

/**
 * The selector matcher has 2 purposes : 
 * - For a given element and selector, it returns wether the element
 * matches the selector
 * - For a given selector, it can return its specificity (its priority)
 *     
 * @author Yannick DOMINGUEZ
 */
class SelectorMatcher
{
    /**
     * class constructor
     */
    private function new() 
    {

    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // PUBLIC SELECTOR MATCHING METHODS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * For a given element and selector, return wether
     * the element matches all of the components of the selector
     */
    public static function match(element:Element, selector:SelectorVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
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
    private static function matchCombinator(element:Element, combinator:CombinatorValue, nextSelectorComponent:SelectorComponentValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
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
    private static function matchGeneralSiblingCombinator(element:Element, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var previousElementSibling = element.previousElementSibling;
        
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
    private static function  matchAdjacentSiblingCombinator(element:Element, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var previousElementSibling = element.previousElementSibling;
        
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
    private static function matchDescendantCombinator(element:Element, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        var parentElement = element.parentElement;
        
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
    private static function matchChildCombinator(element:Element, nextSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
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
    private static function matchSimpleSelectorSequenceStart(element:Element, simpleSelectorSequenceStart:SimpleSelectorSequenceStartValue):Bool
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
    private static function matchSimpleSelectorSequenceItem(element:Element, simpleSelectorSequenceItem:SimpleSelectorSequenceItemValue, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
    {
        switch(simpleSelectorSequenceItem)
        {
            //for this check the list of class of the element    
            case CSS_CLASS(value):
                var classList = element.classList;
                
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
                return PseudoClass.match(element, value, matchedPseudoClasses);    
            
            case ATTRIBUTE(value):
                return Attributes.match(element.getAttribute, value);
        }        
    }
    
    /**
     * Return wether all items in a simple selector
     * sequence are matched
     */
    private static function matchSimpleSelectorSequence(element:Element, simpleSelectorSequence:SimpleSelectorSequenceVO, matchedPseudoClasses:MatchedPseudoClassesVO):Bool
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
}
