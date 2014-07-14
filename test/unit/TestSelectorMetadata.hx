package unit;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.SelectorMetadata;

class TestSelectorMetadata extends BuddySuite implements Buddy {

    public function new()
    {
        describe('selector metadata', function () {
            describe('#getFirstClass', function () {
                it('should return the first class from a selector', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test')]))];
                    SelectorMetadata.getFirstClass(components).should.be('test');
                });

                it('should return null if there are no class', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getFirstClass(components).should.be(null);
                });
            });

            describe('#getFirstId', function () {
                it('should return the first id from a selector', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [ID('test')]))];
                    SelectorMetadata.getFirstId(components).should.be('test');
                });

                it('should return null if there are no id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getFirstId(components).should.be(null);
                });
            });

            describe('#getFirstType', function () {
                it('should return the first type from a selector', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('div'), [ID('test')]))];
                    SelectorMetadata.getFirstType(components).should.be('div');
                });

                it('should return null if there are no type', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getFirstType(components).should.be(null);
                });
            });

            describe('#getIsSimpleClassSelector', function () {
                it('should return true when a selector contains only a class', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test')]))];
                    SelectorMetadata.getIsSimpleClassSelector(components).should.be(true);
                });
                it('should return false  when a selector doesn\'t only contain a class', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test'), ID('pouet')]))];
                    SelectorMetadata.getIsSimpleClassSelector(components).should.be(false);
                });
                it('should return false when a selector has no class', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getIsSimpleClassSelector(components).should.be(false);
                });
            });

            describe('#getIsSimpleIdSelector', function () {
                it('should return true when a selector contains only an id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [ID('test')]))];
                    SelectorMetadata.getIsSimpleIdSelector(components).should.be(true);
                });
                it('should return false  when a selector doesn\'t only contain an id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, [CSS_CLASS('test'), ID('pouet')]))];
                    SelectorMetadata.getIsSimpleIdSelector(components).should.be(false);
                });
                it('should return false when a selector has no id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getIsSimpleIdSelector(components).should.be(false);
                });
            });

            describe('#getIsSimpleTypeSelector', function () {
                it('should return true when a selector contains only a type', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('div'), []))];
                    SelectorMetadata.getIsSimpleTypeSelector(components).should.be(true);
                });
                it('should return false  when a selector doesn\'t only contain an id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(TYPE('div'), [CSS_CLASS('test'), ID('pouet')]))];
                    SelectorMetadata.getIsSimpleTypeSelector(components).should.be(false);
                });
                it('should return false when a selector has no id', function () {
                    var components = [SIMPLE_SELECTOR_SEQUENCE(new SimpleSelectorSequenceVO(UNIVERSAL, []))];
                    SelectorMetadata.getIsSimpleTypeSelector(components).should.be(false);
                });
            });
        });
    }
}

