package unit.parsers;

import buddy.*;
using buddy.Should;

import cocktail.selector.parsers.PseudoClass;
import cocktail.selector.SelectorData;

class TestPseudoClass extends BuddySuite implements Buddy {

    public function new()
    {
        describe('pseudo class parser', function () {
            it('should parse a selector pseudo class', function () {
                var selectors = [];
                var position = PseudoClass.parse('first-child', 0, selectors);
                utest.Assert.same(selectors[0], PSEUDO_CLASS(STRUCTURAL(StructuralPseudoClassSelectorValue.FIRST_CHILD)));
                position.should.be(10);
            });

            it('should return an error for illegal pseudo class', function () {
                var selectors = [];
                var position = PseudoClass.parse('pseudo-pseudo-class', 0, selectors);
                utest.Assert.same(selectors[0], PSEUDO_CLASS(UNKNOWN));
                position.should.be(-1);
            });
        });
    }
}
