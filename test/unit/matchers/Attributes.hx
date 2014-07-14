package unit.matchers;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.matchers.Attributes;


class TestAttributes extends BuddySuite implements Buddy {

    public function new()
    {
        describe('attributes matcher', function () {
            it('should match attribute selector', function () {
                Attributes.match(function (name) return 'test', ATTRIBUTE('test'))
                .should.be(true);
            });

            it('should match attribute value selector', function () {
                Attributes.match(function (name) return 'value', ATTRIBUTE_VALUE('test', 'value'))
                .should.be(true);
            });

            it('should match attribute list selector', function () {
                Attributes.match(function (name) return 'list of value', ATTRIBUTE_LIST('test', 'value'))
                .should.be(true);
            });

            it('should match attribute begins with value selector', function () {
                Attributes.match(function (name) return 'valueofmyselector', ATTRIBUTE_VALUE_BEGINS('test', 'value'))
                .should.be(true);
            });

            it('should match attribute contains value selector', function () {
                Attributes.match(function (name) return 'selectorvaluecontains', ATTRIBUTE_VALUE_CONTAINS('test', 'value'))
                .should.be(true);
            });

            it('should match attribute ends with value selector', function () {
                Attributes.match(function (name) return 'selectorendswithvalue', ATTRIBUTE_VALUE_ENDS('test', 'value'))
                .should.be(true);
            });

            it('should match attribute begins hyphenated list value selector', function () {
                Attributes.match(function (name) return 'value-hyphenated-list', ATTRIBUTE_VALUE_BEGINS_HYPHEN_LIST('test', 'value'))
                .should.be(true);
            });
        });
    }
}
