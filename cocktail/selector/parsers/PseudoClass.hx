package cocktail.selector.parsers;

import cocktail.selector.SelectorData;
using StringTools;

/**
 * CSS Selector pseudo-class parser 
 */
class PseudoClass
{
    //TODO : parse pseudo class with arguments
    public static function parse(selector:String, position:Int, simpleSelectorSequenceItemValues:Array<SimpleSelectorSequenceItemValue>):Int
    {
        var c:Int = selector.fastCodeAt(position);
        var start:Int = position;
        
        while (true)
        {
            if (!isPseudoClassChar(c))
            {
                break;
            }
            c = selector.fastCodeAt(++position);
        }
        
        var pseudoClass:String = selector.substr(start, position - start);
        
        var typedPseudoClass:PseudoClassSelectorValue = PseudoClassSelectorValue.UNKNOWN;
        
        switch(pseudoClass)
        {
            case 'first-child':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.FIRST_CHILD);
                
            case 'last-child':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.LAST_CHILD);
        
            case 'empty':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.EMPTY);
                
            case 'root':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ROOT);
                
            case 'first-of-type':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.FIRST_OF_TYPE);    
                
            case 'last-of-type':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.LAST_OF_TYPE);    
                
            case 'only-of-type':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ONLY_OF_TYPE);    
                
            case 'only-child':
                typedPseudoClass = PseudoClassSelectorValue.STRUCTURAL(StructuralPseudoClassSelectorValue.ONLY_CHILD);
                
            case 'link':
                typedPseudoClass = PseudoClassSelectorValue.LINK(LinkPseudoClassValue.LINK);    
                
            case 'visited':
                typedPseudoClass = PseudoClassSelectorValue.LINK(LinkPseudoClassValue.VISITED);
                
            case 'active':
                typedPseudoClass = PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.ACTIVE);
                
            case 'hover':
                typedPseudoClass = PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.HOVER);
                
            case 'focus':
                typedPseudoClass = PseudoClassSelectorValue.USER_ACTION(UserActionPseudoClassValue.FOCUS);
                
            case 'target':
                typedPseudoClass = PseudoClassSelectorValue.TARGET;

            case 'fullscreen':
                typedPseudoClass = PseudoClassSelectorValue.FULLSCREEN;
                
            case 'nth-child':
                //TODO
                
            case 'nth-last-child':
                //TODO
                
            case 'nth-of-type':
                //TODO
                
            case 'nth-last-of-type':
                //TODO
                
            case 'not':
                //TODO
                
            case 'lang':
                //TODO
                
            case 'enabled':
                typedPseudoClass = PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.ENABLED);
                
            case 'disabled':
                typedPseudoClass = PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.DISABLED);
                
            case 'checked':
                typedPseudoClass = PseudoClassSelectorValue.UI_ELEMENT_STATES(UIElementStatesValue.CHECKED);
                
        }

        
        simpleSelectorSequenceItemValues.push(SimpleSelectorSequenceItemValue.PSEUDO_CLASS(typedPseudoClass));
        
        //selector is invalid
        if (typedPseudoClass == PseudoClassSelectorValue.UNKNOWN)
        {
            return -1;
        }
        return --position;
    }

    static inline function isPseudoClassChar(c) {
        return isAsciiChar(c) || c == '-'.code;
    }

    static inline function isAsciiChar(c) {
        return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code);
    }
}
