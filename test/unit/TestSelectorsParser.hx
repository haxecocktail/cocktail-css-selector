package unit;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.SelectorsParser;

class TestSelectorsParser extends BuddySuite implements Buddy {

    public function new()
    {
        describe('selectors parser', function () {

            it('should parse multiple selectors', function () {
                var selectors = SelectorsParser.parse('div, p');
                selectors.length.should.be(2);
                utest.Assert.same(selectors[0].components, [
                    SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                ]);
                utest.Assert.same(selectors[1].components, [
                    SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('P'), []))
                ]);
            });

            it('should make all selectors invalid if one of them is invalid', function () {
                var selectors = SelectorsParser.parse('div, ~');
                selectors.should.be(null);
            });
        });
    }
}


