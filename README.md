[![Build Status](https://travis-ci.org/haxecocktail/cocktail-css-selector.svg?branch=master)](https://travis-ci.org/haxecocktail/cocktail-css-selector)

cocktail-css-selector
=====================

CSS selector matching, parsing and serializing.
This lib is part of the larger [Cocktail project](https://github.com/haxecocktail/cocktail).

## Install

```
haxelib install cocktail-css-selector
```

## Usage

### Selectors parsing

```Haxe

//parser class
import cocktail.selector.SelectorsParser;

//Selectors data structures
import cocktail.selector.SelectorData;

class Main {
  public static function main() {
  
    //parse one or multiple selectors and return them in an array of SelectorVO 
    //(see SelectorData implementation)
    var selectors = SelectorsParser.parse('div, p');
  }
}

```

### Selectors matching

```Haxe

//matcher class
import cocktail.selector.SelectorMatcher;

//Selectors data structures
import cocktail.selector.SelectorData;

//DOM lib
import cocktail.dom.*;

class Main {
  public static function main() {

    //create the DOM node to match
    var element = new Document().createElement('div');
  
    //takes a DOM node and a
    //selector and returns whether the element matches the 
    //selector
    var isMatched = SelectorMatcher.match(element, 'div');

    //an optional object can be provided specifiying which pseudo-class
    //(hover, active, fullscreen... are currently active in the document).
    //It is only useful for interactive documents
    var matchedPseudoClasses = new MatchedPseudoClassesVO(//bunch of flags);

    isMatched = SelectorMatcher.match(element, 'div', matchedPseudoClasses);
  }
}

```

## Run Tests

```
make
```
