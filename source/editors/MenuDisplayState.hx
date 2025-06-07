package editors;

// Haxe 4.2.5, Flixel 5.2.2 \\

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxObject;
import StringTools;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIButton;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.io.File;
import sys.FileSystem;

class MenuDisplayState extends MusicBeatState {
    //-----------//
    // VARIABLES //
    //-----------//


    var backdrop:FlxBackdrop = new FlxBackdrop(Paths.image('menuBG'), true, true, 0, 0);
    var backdropOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);

    var currentMenusBox:FlxSprite;
    var currentMenusTxt:FlxText;


    var tabMenu:FlxUITabMenu;
    var addMenuUI:FlxUI;
    var orderMenuUI:FlxUI;
    var menuSettingsUI:FlxUI;

    var addMenuButton:FlxUIButton;
    var newMenuNameInput:FlxUIInputText;

    var menuGroup:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;

    // Debug \\

    var restartOriginalY:Float;

    var debugTextY:FlxText;
    var debugTextX:FlxText;

    var debugging:Bool = false;

    //------\\

    //-----------//
    // FUNCTIONS //
    //-----------//

    


    function addUI() 
    {
        // Menu //

        tabMenu = new FlxUITabMenu
        (
            null,
            [ 
                {name:"Add Menu", label:"Add Menu"},
                {name:"Order Menus", label:"Order Menus"},
                {name:"Menu Settings", label:"Menu Settings"}
            ]
        );
        tabMenu.resize(300, 200);
        tabMenu.setPosition(900, 50);
        add(tabMenu);

        // Tabs //
        addMenuUI = new FlxUI(null, this);
        addMenuUI.name = "Add Menu";
        //add(addMenuUI);

        orderMenuUI = new FlxUI(null, this);
        orderMenuUI.name = "Order Menus";
        //add(orderMenuUI);

        menuSettingsUI = new FlxUI(null, this);
        menuSettingsUI.name = "Menu Settings";
        //add(menuSettingsUI);

        tabMenu.addGroup(addMenuUI);
        tabMenu.addGroup(orderMenuUI);
        tabMenu.addGroup(menuSettingsUI);

        // Add Menu UI //

        newMenuNameInput = new FlxUIInputText(25, 25, "Enter Menu Name", 8);
        addMenuUI.add(newMenuNameInput);

        addMenuButton = new FlxUIButton(200, 20, "Add Menu");
        addMenuUI.add(addMenuButton);
    }

    function backdropHandler() {
        add(backdrop);
        add(backdropOverlay);
        backdrop.velocity.set(100, 100);
        backdrop.scrollFactor.set();
        backdropOverlay.alpha = 0.5;
    }

    override function create() 
    {
        super.create();

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Looking at Menus...", null);
		#end

        FlxG.mouse.visible = true;

        backdropHandler();
        addUI();

        menuGroup = new FlxTypedGroup<Alphabet>();
        add(menuGroup);

        currentMenusBox = new FlxSprite(20, 20).makeGraphic(250, 50, 0xFF000000);
        currentMenusTxt = new FlxText(-110, 30, 500, "Current Menus", 25);
        currentMenusTxt.setFormat(Paths.font('vcr.ttf'), 25, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        currentMenusBox.scrollFactor.set();
        currentMenusTxt.scrollFactor.set();

        add(currentMenusBox);
        add(currentMenusTxt);


        
        /*
        for (i in 0...directory.length) {
            var menuPlaceholder:Alphabet = new Alphabet(20, 90, "PLACEHOLDER MENU", true);
            menuPlaceholder.y += menuPlaceholder.height * i;
            menuPlaceholder.y += distanceY * i;
            menuGroup.add(menuPlaceholder);
        } 
        */

        var distanceY:Int = 100;
        var folderPath = Paths.menus(); // Example: "assets/data/menus"
        if (FileSystem.exists(folderPath) && FileSystem.isDirectory(folderPath)) {
            var files = FileSystem.readDirectory(folderPath);
            var count:Int = -1;
            for (fileName in files) {
                count++;
                var displayName = StringTools.replace(fileName.split(".")[0], "-", " ");
                var menuButton:Alphabet = new Alphabet(20, 90, displayName, true);
                menuButton.targetY = count;
                /*
                menuButton.y += menuButton.height * count;
                menuButton.y += distanceY * count;
                */
                menuButton.isMenuItem = true;
                menuGroup.add(menuButton);
            } 
        } else {
            trace('Directory not found: $folderPath');
        }


        if (debugging) debuggingText();


        changeSelection();
    }
    
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            MusicBeatState.switchState(new MainMenuState());
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
        
        // -1 = UP
        // 1 = DOWN


        // Selecting Stuff
        if (controls.UI_UP_P) {
            changeSelection(-1, true);
        }
        
        if (controls.UI_DOWN_P) {
            changeSelection(1, true);
        }

        if (FlxG.mouse.wheel != 0) {
            changeSelection(0 - FlxG.mouse.wheel);
        }

        // Accepting
        if (controls.ACCEPT)
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            MusicBeatState.switchState(new MenuEditorState());
        }


        if (debugging) updateDebug();
    }

    public function changeSelection(?changeBy:Int, ?tween:Bool) {
            FlxG.sound.play(Paths.sound('scrollMenu'));

            // Handle selection wrapping
            if (changeBy != null) {
                var maxIndex = menuGroup.members.length - 1;

                if (curSelected <= 0 && changeBy < 0) {
                    curSelected = maxIndex;
                } else if (curSelected >= maxIndex && changeBy > 0) {
                    curSelected = 0;
                } else {
                    curSelected += changeBy;
                }
           }

           // Update visual state of each menu item
           for (i in 0...menuGroup.members.length) {
                var item = menuGroup.members[i];
                if (item == null) continue;

                var targetAlpha = (i == curSelected) ? 1 : 0.5;

                if (tween == true) {
                    FlxTween.tween(item, { alpha: targetAlpha }, 0.05);
                } else {
                   item.alpha = targetAlpha;
                }
            }
        }

    public function debuggingText()
        {
            debugTextY = new FlxText(12, FlxG.height - 44, 0, "Y: " + addMenuButton.y, 12);
		    debugTextY.scrollFactor.set();
		    debugTextY.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(debugTextY);

            debugTextX = new FlxText(12, FlxG.height - 24, 0, "X: " + addMenuButton.x, 12);
		    debugTextX.scrollFactor.set();
		    debugTextX.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(debugTextX);
        }

    public function updateDebug() {
            debugTextY.text = "Y: " + addMenuButton.y;
            debugTextX.text = "X: " + addMenuButton.x;

            if (FlxG.keys.pressed.LEFT) {
                addMenuButton.x -= 1;
            }
            if (FlxG.keys.pressed.RIGHT) {
                addMenuButton.x += 1;
            }
            if (FlxG.keys.pressed.UP) {
                addMenuButton.y -= 1;
            }
            if (FlxG.keys.pressed.DOWN) {
                addMenuButton.y += 1;
            } 
    }
}