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
                CSSSelectorParser.parse('*').should.not.be(null);
                CSSSelectorParser.parse('div').should.not.be(null);
                CSSSelectorParser.parse('.class').should.not.be(null);
                CSSSelectorParser.parse('#id').should.not.be(null);
            });

            it('should detect an invalid selector', function () {
                CSSSelectorParser.parse('~').should.be(null);
            });

            describe('simple selector', function () {
                it('should parse universal selector', function () {
                    var selector =  CSSSelectorParser.parse('*' );
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))
                    ]);
                });
                it('should parse type selector', function () {
                    var selector = CSSSelectorParser.parse('div');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
                it('should parse class selector', function () {
                    var selector = CSSSelectorParser.parse('.test');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test')]))
                    ]);
                });
                it('should parse attribute selector', function () {
                    var selector = CSSSelectorParser.parse('[test]');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE('test'))]))
                    ]);
                });
                it('should parse pseudo-element selector', function () {
                    var selector = CSSSelectorParser.parse('*::first-line');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))
                    ]);

                    selector.pseudoElement.should.be(FIRST_LINE);
                });
                it('should parse pseudo-class selector', function () {
                    var selector = CSSSelectorParser.parse(':target');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [PSEUDO_CLASS(TARGET)]))
                    ]);
                });
            });

            describe('combinators', function () {

                it('should parse descendant combinators', function () {
                    var selector = CSSSelectorParser.parse('div p');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('P'), [])),
                        COMBINATOR(DESCENDANT),
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
                it('should parse child combinators', function () {
                    var selector = CSSSelectorParser.parse('div > p');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('P'), [])),
                        COMBINATOR(CHILD),
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
                it('should parse adjacent sibling combinators', function () {
                    var selector = CSSSelectorParser.parse('div + p');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('P'), [])),
                        COMBINATOR(ADJACENT_SIBLING),
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
                it('should parse general sibling combinators', function () {
                    var selector = CSSSelectorParser.parse('div ~ p');
                    utest.Assert.same(selector.components, [
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('P'), [])),
                        COMBINATOR(GENERAL_SIBLING),
                        SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('DIV'), []))
                    ]);
                });
            });
        });
    }
}


