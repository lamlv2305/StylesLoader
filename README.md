StylesLoader: get style properties from json file then apply to specific view
======================================

## At a glace:

Did you have to set color, font, size ... for any UIView subclass.
> Eg:
```swift
let view = UIView()
view.backgroundColor = UIColor.black
view.clipToBounds = true
view.layer.cornerRadisus = 4
view.layer.borderWidth = 4
view.layer.borderColor = UIColor.red.cgColor
```

> I used to make a utilities class and copy/paste to all view/label/button style, dupplicated code to archive what I want. 

> At a bad day, designer come and said: "Hey buddy, these button color is wrong, you have to change all of them to red instead of black". 
> Well, i'm flexible developer, it's not a problem.
> On next day, BA has new US, need to make a new style with different color for button, different font for all app, diffirent color for some places. 

**WTF, I just changed it yesterday, why didn't you tell me ?????? I have to refactor 1 more times, I have to test all of changes, blah blah blah**
> Nobody care, they want instant change with current app with a new design or a.....

## Usage:

Define your styles in a .json file 
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
    .register(GeneralStyleProvider())
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

## Installation:
TODO: 

## Usage:
TODO:
