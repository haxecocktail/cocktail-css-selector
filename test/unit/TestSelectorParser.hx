package unit;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.SelectorParser;

class TestSelectorParser extends BuddySuite implements Buddy {

    public function new()
    {
        describe('selector parser', function () {
            it('should detect a valid selector', function () {
                CSSSelectorParser.parse('*', []).should.be(true);
                CSSSelectorParser.parse('div', []).should.be(true);
                CSSSelectorParser.parse('.class', []).should.be(true);
                CSSSelectorParser.parse('#id', []).should.be(true);
            });

            it('should detect an invalid selector', function () {
                CSSSelectorParser.parse('~', []).should.be(false);
            });

            describe('simple selectors', function () {
                it('should parse universal selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse('*', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))
                    ]);
                });
                it('should parse type selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse('div', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
                it('should parse class selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse('.test', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test')]))
                    ]);
                });
                it('should parse attribute selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse('[test]', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE('test'))]))
                    ]);
                });
                it('should parse pseudo-element selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse('*::first-line', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))
                    ]);

                    selectors[0].pseudoElement.should.be(FIRST_LINE);
                });
                it('should parse pseudo-class selector', function () {
                    var selectors = [];
                    CSSSelectorParser.parse(':target', selectors);
                    selectors.length.should.be(1);
                    utest.Assert.same(selectors[0].components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [PSEUDO_CLASS(TARGET)]))
                    ]);
                });
            });

            describe('combinators', function () {
                it('should parse descendant combinators');
                it('should parse child combinators');
                it('should parse adjacent sibling combinators');
                it('should parse general sibling combinators');
            });

            describe('selectors', function () {
                it('should parse multiple selectors');
            });
        });
    }
}


