package unit.parsers;

import buddy.*;
using buddy.Should;

import cocktail.selector.parsers.Attribute;
import cocktail.selector.SelectorData;

class TestAttribute extends BuddySuite implements Buddy {

    public function new()
    {

        describe('selector attribute parser', function () {

            var testAttribute = function (selector:String, expected:SimpleSelectorSequenceItemValue) {
                var selectors = [];
                var position = Attribute.parse(selector, 0, selectors);
                utest.Assert.same(selectors[0], expected);
                return position;
            }

            it('should parse an attribute selector', function () {
                testAttribute('[test]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE('test')));
            });

            it('should parse an attribute with value selector', function () {
                testAttribute.bind('[foo=bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE('foo', 'bar')));
            });

            it('should parse an attribute beginning with a value selector', function () {
                testAttribute.bind('[foo^=bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS('foo', 'bar')));

            });
            it('should parse an attribute list selector', function () {
                testAttribute('[foo~=bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_LIST('foo', 'bar')));
            });

            it('should parse an attribute ends with value selector', function () {
                testAttribute( '[foo$=bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_ENDS('foo', 'bar')));
            });

            it('should parse an attribute where value contains selector', function () {
                testAttribute( '[foo*=bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_CONTAINS('foo', 'bar')));
            });

            it('should parse an attribute hyphenated list selector', function () {
                testAttribute( '[foo|=bar-bar]', SimpleSelectorSequenceItemValue.ATTRIBUTE(AttributeSelectorValue.ATTRIBUTE_VALUE_BEGINS_HYPHEN_LIST('foo', 'bar-bar')));
            });

            it('should return an error for illegal attribute', function () {
                var position = Attribute.parse('[foo ad d jbar]', 0, []);
                position.should.be(-1);
            });
        });
    }
}
