package unit;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.SelectorSpecificity;

class TestSelectorSpecificity extends BuddySuite implements Buddy {

    public function new()
    {
        describe('selector specificity', function () {
            it('should get a selector specificity', function () {
                var components = [
                    SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [ID('div')]))
                ];
                var selector = new SelectorVO(components, NONE, false, '', false, '', false, 
                    '', false, false, false);

                SelectorSpecificity.get(selector).should.be(100);
            });
        });
    }
}

