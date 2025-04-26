package editors;

// Haxe 4.2.5, Flixel 5.2.2 \\

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIButton;


class MenuDisplayState extends MusicBeatState {
    //-----------//
    // VARIABLES //
    //-----------//

    var backdrop:FlxBackdrop = new FlxBackdrop(Paths.image('menuBG'), true, true, 0, 0);
    var backdropOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);

    var currentMenusBox:FlxSprite;
    var currentMenusTxt:FlxText;

    var menuPlaceholder:FlxText;


    var tabMenu:FlxUITabMenu;
    var addMenuUI:FlxUI;
    var orderMenuUI:FlxUI;
    var menuSettingsUI:FlxUI;

    var addMenuButton:FlxUIButton;
    var newMenuNameInput:FlxUIInputText;

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
        backdropOverlay.alpha = 0.5;
    }

    override function create() 
    {
        super.create();

        FlxG.mouse.visible = true;

        backdropHandler();
        addUI();

        currentMenusBox = new FlxSprite(20, 20).makeGraphic(250, 50, 0xFF000000);
        currentMenusTxt = new FlxText(-110, 30, 500, "Current Menus", 25);
        currentMenusTxt.setFormat(Paths.font('vcr.ttf'), 25, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        add(currentMenusBox);
        add(currentMenusTxt);


        
        menuPlaceholder = new FlxText(-125, 90, 750, "PLACEHOLDER MENU", 50);
        menuPlaceholder.setFormat(Paths.font('vcr.ttf'), 50, FlxColor.BLACK, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
        menuPlaceholder.bold = true;
        
        add(menuPlaceholder);

        if (debugging) debuggingText();
    }
    
    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (debugging) updateDebug();
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