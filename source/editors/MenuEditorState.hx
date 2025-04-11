package editors;

// Haxe 4.2.5, Flixel 5.2.2

#if desktop
import Discord.DiscordClient;
#end

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;

class MenuEditorState extends MusicBeatState {
    
    //====================//
    // Variables
    //====================//
    var bg:FlxSprite;
    var tab_editorbox:FlxUITabMenu;
    var editorTab:FlxUI;
    var newButtonName:FlxUIInputText;

    //====================//
    // UI Setup Function
    //====================//
    function addUI() {
        // Create tab menu
        tab_editorbox = new FlxUITabMenu(
            null,
            [{ name: "Creation", label: "Creation" }],
            true
        );
        tab_editorbox.resize(300, 200);
        tab_editorbox.setPosition(900, 50);
        add(tab_editorbox);

        // Create the "Creation" tab and input field
        editorTab = new FlxUI(null, this);
        editorTab.name = "Creation";
        add(editorTab);

        newButtonName = new FlxUIInputText(
            tab_editorbox.x + 10, 
            tab_editorbox.y + 25, 
            200, 
            "Enter Button Name"
        );
        editorTab.add(newButtonName);
    }

    //====================//
    // Lifecycle: create
    //====================//
    override function create() {
        #if desktop
        DiscordClient.changePresence("Editing Menus", null);
        #end

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF6B6B6B;
        add(bg);

        addUI();
    }
}
