package editors;

// Haxe 4.2.5, Flixel 5.2.2

#if desktop
import Discord.DiscordClient;
#end

import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUIButton;

typedef MenuData = 
{

    objectImage:Array<String>,
    type:String

}

class MenuEditorState extends MusicBeatState {
    
    //====================//
    // Variables
    //====================//
    public static var menuJSON:MenuData;
    //=================//
    // UI
    //=================//
    var tabMenu:FlxUITabMenu;
    var creationTab:FlxUI;
    
    var newButtonName:FlxUIInputText;
    var addNewButton:FlxUIButton;

    private var camEditor:FlxCamera;
	private var camHUD:FlxCamera;
    //=================//
    // JSON
    //=================//
    public var curMenuJson:String = "main-menu";

    //====================//
    // UI Setup Function
    //====================//
    function addUI() {
        // Create tab menu
        tabMenu = new FlxUITabMenu
        (
            null,
            [
                { name: "Creation", label: "Creation" }
            ],
            true
        );
        tabMenu.resize(300, 200);
        tabMenu.setPosition(900, 50);
        tabMenu.scrollFactor.set();
        add(tabMenu);

        // Tabs
        creationTab = new FlxUI(null, this);
        creationTab.name = "Creation";

        tabMenu.addGroup(creationTab);

        /* --Content-- */

        // Creation
        newButtonName = new FlxUIInputText(
            10, 
            25, 
            200, 
            "Enter Image Name"
        );
        addNewButton = new FlxUIButton(
            10, 
            50, 
            "Add Image",
            () -> addImage(newButtonName.text)
        );
        creationTab.add(newButtonName);
        creationTab.add(addNewButton);
    }

    public function addImage(name:String)
    {
        var obj:FlxSprite = new FlxSprite();
        obj.loadGraphic(name);
        obj.screenCenter(); 
        add(obj);
    }

    //====================//
    // Lifecycle: create
    //====================//
    override function create() {
        super.create();

        camEditor = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camEditor);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camEditor, true);

        #if desktop
        DiscordClient.changePresence("Editing Menus", null);
        #end

        menuJSON = Json.parse(Paths.getTextFromFile('menus/' + curMenuJson + '.json'));


        // Background Characters
        for (i in 0...menuJSON.objectImage.length) {
            var obj:FlxSprite = new FlxSprite();
            obj.loadGraphic(Paths.image(menuJSON.objectImage[i]));
            add(obj);
        }

        if (menuJSON.type == 'Main-Menu')
        {
            var template:FlxSprite = new FlxSprite();
            template.loadGraphic(Paths.image('mainmenu/template'));
            template.alpha = 0.25;
            template.scrollFactor.set(0, 0.135);
            template.screenCenter();
            add(template);
        }

        /*
        bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
        add(bg);
        */
        

        addUI();

        tabMenu.cameras = [camHUD];




    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            // ESCAPE MENU
            MusicBeatState.switchState(new MenuDisplayState());
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }

        if (FlxG.keys.pressed.E) {
            // ZOOM IN
            FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if(FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
        }

        if (FlxG.keys.pressed.Q) {
            // ZOOM OUT
            FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if(FlxG.camera.zoom > 3) FlxG.camera.zoom = 3;
        }
    
    }
}
