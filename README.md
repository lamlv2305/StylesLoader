# StylesLoader
## Get style properties from json file then apply to specific view
======================================

![Showcase image](/Showcase.png)

## At a glace:

Every ios-app has something like:

 - Button
 - Label
 - View
 - ....
 
For example, button has submit, cancel, verify, back .. styles. You have to set button's attributes/properties to archive a smooth, good looking, and friendly app.

We usually did it by these ways:

```swift
let button = UIButton(frame: ....)
button.clipToBounds = true
button.layer.cornerRadius = 4
button.layer.shadowOpacity = 0.15
button.layer.shadowOffset = CGSize(width: 0, height: 3)
button.backgroundColor = UIColor.red 
```

Or 

```swift
class CustomButton: UIButton {
    func draw() {
        // Do something for your button
    }
}
```

The 1st way is flexible but we have copy/paste to apply on new object. The 2nd way make it central control, apply to all object when we need to change but we have to create a new class with a lot of override/changes inside.

We known both advantages and disadvantages, why don't we try to make it better ?

## General Ideas:

What do I need to make it better ?

- Flexible changes
- Change apply to all sub-class
- Easy to add/edit/remove a new property
- Easy to use ( 1 line to apply )

So StylesLoader has been done by:
- Load config/styles from json file. ( from url files in futures )
- Apply styles on runtime by StyleProvider
- Styles on json, but we have specific using by register ```perform(with:on)``` functions
- Make an extension for UIView, where we can easily to apply style with 1 line of code ( and have a ton of codes behind that xD )

Read config file is not a good ideas, because of:
- Safe typing 
- Autocomplete
- Hard to maintain when we don't have a clearly understand. Did that property what I just edit/remove was using by any providers ?
- Not familiar with any kind of styles world. Everyline in json was defined and used by provider and will be ignored in runtime if noone need them.

> Damn it, you know it has a lot of ugly edges. Why did you using this ?????? !@#$@$%WR@#%#^

Well, flexible, that's all.

## Usage:

Define your styles in a `*.json` file. I named it `themes.json`:
```json
{
    "color": {
        "$whiteSmoke" : "#000000ff",
        "$blue": "#0000ffff"
    },
    "font": {
        "@palatino": "Palatino"
    },
    "customVariables": {
        "~alignCenter": 1,
        "~alignLeft": 0
    },
    "styles": {
        ".banner": {
            "backgroundColor" : "$blue",
            "borderWidth": 2,
            "borderColor" : "$whiteSmoke",
            "cornerRadius" : 5
        },
        ".h1": {
            "parent": ".banner",
            "textColor": "$blue",
            "textAlign": "~alignCenter",
            "fontSize": 13,
            "fontName": "@palatino"
        }
    }
}
```

Add StylesLoader's configuration in ```AppDelegate.swift```

```swift
import StylesLoader

func application(
  _ application: UIApplication, 
  didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
) -> Bool {
  StylesResources.shared.load(from: "themes")
  StylesResources.shared
    .register(LayerStyleProvider())
    .register(TextStyleProvider())
    
  // TODO: Add your code here
  
  return true
}

```

then load to view:

```swift
import StylesLoader

let label = UILabel()
label.styles.loadStyles(".h1")
```

By default, StylesLoader using `StylesResources.shared` as its resources. More customization can be applied by provide another `resources` what inherited from `StylesResources`

```swift
label.styles.loadStyles(".h1", from: MyResources.singleton)
```

## What does JSON file have ?

### color
*Color key has `$` prefix, and value has `#` prefix*

Color is #RGBA color, need to follow exactly format to validate color.

If you hate that format, just edit `var hexColor: UIColor?` in `Ext+StylesLoader.swift`

### font

*Font key has `@` prefix*

Font name will be verified to prevent crash in runtime.

### customVariables

*Custom variables key has `~` prefix*

For example: you need text align left and center, but it was mark as number, so give it a name to clearly on using.

### styles
*Styles is json object with `parent` optional. If styles object has `parent` key, it mean that styles will inherit from `parent styles` and will override the same attributes, like OOP*

## Can I make my custom key, such as: "GiveMeMana" ?
Of course, you do. 

By default, StylesLoader has 2 providers: `LayerStyleProvider`, `TextStyleProvider`. You can create your new `StylesProvider` then register in `application(_:didFinishLaunchingWithOptions)`

StylesLoader will ignore unregistered style keys. So don't forget to `register(_:)`

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)


```ruby
# Podfile
use_frameworks!
platform :ios, '9.0'

target 'YOUR_TARGET_NAME' do
    pod 'StylesLoader'
end
```

## TODO:
- Installation
- Unit test
- UI test


