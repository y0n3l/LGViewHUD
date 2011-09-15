LGViewHUD
=========
A HUD that mimics the native one used in iOS (when you press volume up or down on the iPhone for instance) and also provides some more features (some more animations + activity indicator support included.)

Code example:
=============
    #import "LGViewHUD.h"
    ..
    
    
    #in a UIViewController ....
    LGViewHUD* hud = [LGViewHUD defaultHUD];
    hud.image=[UIImage imageNamed:@"rounded-checkmark.png"];
    hud.topText=@"Done !";
    hud.bottomText=@"Great !";  
	
    # show it in current view (it will disappear 2 sec later)
    [hud showInView:self.view]
    
    #with an activity indicator
    hud.activityIndicatorOn=YES;
    