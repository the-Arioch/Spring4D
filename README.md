Upstream repo: https://bitbucket.org/sglienke/spring4d

Differences:

1. mostly last official stable 1.1.4 (Stefan says the bleeding edge 2 alpha 2 is de facto more stable for Delphi 10.x, though)

2. added demo for "auto clock-cursor events" for building GUI, using some Deltics code too, [bug 52](https://bitbucket.org/sglienke/spring4d/issues/52/).

3. fixed [bug 338](https://bitbucket.org/sglienke/spring4d/issues/338) - the stock installer tells a developer intallation was OK when unit tests failed. Due to a typo in GUI calling code. Stefan, sadly, says "not a bug".

-----------

![Spring4D medium.png](https://bitbucket.org/repo/jxX7Lj/images/3496466100-Spring4D%20medium.png)


Spring4D is an open-source code library for Embarcadero Delphi 2010 and higher.
It consists of a number of different modules that contain a base class library (common types, interface based collection types, reflection extensions) and a dependency injection framework. It uses the Apache License 2.0.

Join us on the [Spring4D Google Group](https://groups.google.com/forum/#!forum/spring4d).

Installation
------------
Just run the Build.exe and select the Delphi versions you want to install Spring4D for.

Current version
---------------
1.2.4 (2020-05-27)

Known issues
------------
* Some warnings when compiling for mobile compilers.
* The deployment of the unit test project might fail for mobile compilers (iOS ARM and Android).
* Compilation on some older versions for iOS and Android might fail due to compiler bugs.

Please support us
-----------------
[![btn_donate_LG.gif](https://bitbucket.org/repo/jxX7Lj/images/1283204942-btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KG4H9QT3MSDN8)


Copyright (c) 2009 - 2018 Spring4D Team
