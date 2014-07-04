package unit.parsers;

import buddy.*;
using buddy.Should;

import cocktail.selector.parsers.PseudoElement;
import cocktail.selector.SelectorData;

class TestPseudoElement extends BuddySuite implements Buddy {

    public function new()
    {
        describe('pseudo element parser', function () {

            it('should parse a selector pseudo element', function () {
                var selector = new SelectorVO([], PseudoElementSelectorValue.NONE,
                false, null, false, null, false, null, false, false, false);
                var position = PseudoElement.parse('first-line', 0, selector);
                utest.Assert.same(selector.pseudoElement, FIRST_LINE);
                position.should.be(9);
            });

            it('should detect no pseudo element', function () {
                var selector = new SelectorVO([], PseudoElementSelectorValue.NONE,
                false, null, false, null, false, null, false, false, false);
                var position = PseudoElement.parse('pseudo-pseudo-element', 0, selector);
                utest.Assert.same(selector.pseudoElement, PseudoElementSelectorValue.NONE);
                position.should.be(20);
            });
        });
    }
}
