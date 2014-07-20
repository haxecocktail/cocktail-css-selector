package unit.matchers;

import buddy.*;
using buddy.Should;

import cocktail.selector.SelectorData;
import cocktail.selector.matchers.PseudoClass;
import cocktail.dom.*;


class TestPseudoClass extends BuddySuite implements Buddy {

    public function new()
    {
        var element, matchedPseudoClasses, document;
        before(function () {
            document = new Document();
            element = document.createElement('div');
            matchedPseudoClasses = new MatchedPseudoClassesVO(
                false, false, false, false, false, false, false, false, false, false,
                null, null, null);
        });
        describe('pseudo class matcher', function () {

            describe('match structural pseudo class', function () {
                it('should match empty pseudo class', function () {
                    PseudoClass.match(element, STRUCTURAL(EMPTY), matchedPseudoClasses)
                    .should.be(true);
                });

                it('should match first-child pseudo-class', function () {
                    var parent = document.createElement('div');
                    parent.appendChild(element);

                    PseudoClass.match(element, STRUCTURAL(FIRST_CHILD), matchedPseudoClasses)
                    .should.be(true);
                });

                it('should match last-child pseudo-class', function () {
                    var parent = document.createElement('div');
                    parent.appendChild(element);

                    PseudoClass.match(element, STRUCTURAL(LAST_CHILD), matchedPseudoClasses)
                    .should.be(true);
                });

                it('should match only-child pseudo-class', function () {
                    var parent = document.createElement('div');
                    parent.appendChild(element);

                    PseudoClass.match(element, STRUCTURAL(ONLY_CHILD), matchedPseudoClasses)
                    .should.be(true);
                });

                it('should match root pseudo-class', function () {
                    element = document.createElement('HTML');
                    document.appendChild(element);
                    PseudoClass.match(document.documentElement, STRUCTURAL(ROOT), matchedPseudoClasses)
                    .should.be(true);
                });

                it('should match only of type pseudo class');
                it('should match first of type pseudo class');
                it('should match last of type pseudo class');

                it('should match nth child');
            });

            it('should match the link pseudo-class', function () {
                matchedPseudoClasses.link = true;
                PseudoClass.match(element, LINK(LinkPseudoClassValue.LINK), matchedPseudoClasses)
                .should.be(true);
            });

            describe('user action pseudo class', function () {
                it('should match active pseudo class');
                it('should match hover pseudo class');
                it('should match focus pseudo class');
            });

            it('should match the target pseudo-classes');
            it('should match the negation pseudo-selector');
            it('should match the lang pseudo-selector');

            describe('ui states', function () {
                it('should match the checked pseudo class');
                it('should match the disabled pseudo class');
                it('should match the enabled pseudo class');
            });

            it('should match the UI element states selector');
            it('should match the fullscreen pseudo class');
        });
    }
}
