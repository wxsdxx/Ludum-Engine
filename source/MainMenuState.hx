package;

#if desktop
import Discord.DiscordClient;
#end
import haxe.Json;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

typedef MenuData = 
{
	
	backgroundSprite:String,
	backgroundDesatSprite:String,
	cameraMove:Bool,
	buttons:Array<String>,
	font:String,
	fontOutline:Bool,
	ludumEngineVersion:Bool,
	objects:Array<String>,
	objectBehindButtons:Array<Bool>,
	objectSprites:Array<String>,
	objectX:Array<Float>,
	objectY:Array<Float>,
	objectAnimated:Array<Bool>,
	objectAnimationName:Array<String>,
	objectAnimationFrames:Array<Int>,
	objectCenteredAcrossX:Array<Bool>,
	objectCenteredAcrossY:Array<Bool>

}
class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var ludumEngineVersion:String = '0.0.1';
	public static var curSelected:Int = 0;

	public static var menuJSON:MenuData;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String>;
	/*
	[
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		#if !switch 'donate', #end
		'credits',
		'options'
	];
	*/

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	function createObject(i) {
		var v:FlxSprite = new FlxSprite(menuJSON.objectX[i],menuJSON.objectY[i]);
		menuJSON.objectAnimated[i] 
			? v.frames = Paths.getSparrowAtlas(menuJSON.objectSprites[i])
			: v.loadGraphic(Paths.image(menuJSON.objectSprites[i]));

		if (menuJSON.objectAnimated[i]) {
			v.animation.addByPrefix('idle', menuJSON.objectAnimationName[i], menuJSON.objectAnimationFrames[i]);
			v.animation.play('idle');
		}

		if (menuJSON.objectCenteredAcrossX[i]) { v.screenCenter(X); }
		if (menuJSON.objectCenteredAcrossY[i]) { v.screenCenter(Y); }
		v.scrollFactor.set();
		add(v);
	}

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		menuJSON = Json.parse(Paths.getTextFromFile('images/menuTitleSettings.json'));

		optionShit = menuJSON.buttons;

		var yScroll:Float;
		if (menuJSON.cameraMove) {
			yScroll = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		} else {
			yScroll = 0;
		}
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image(menuJSON.backgroundSprite));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		//bg.color = 0xfffbff00;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image(menuJSON.backgroundDesatSprite));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		for (i in 0...menuJSON.objects.length) {
			if (menuJSON.objectBehindButtons[i]) {
				createObject(i);
			}
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float;
			if (menuJSON.cameraMove) {
				scr = (optionShit.length - 4) * 0.135;
			} else {
				scr = 0;
			}
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var ludumVersionText:FlxText = new FlxText(12, FlxG.height - 54, 0, "Ludum Engine v" + ludumEngineVersion, 12);
		ludumVersionText.scrollFactor.set();

		if (menuJSON.ludumEngineVersion) { add(ludumVersionText); }

		var psychVersionText:FlxText = new FlxText(12, FlxG.height - 54, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVersionText.scrollFactor.set();
		#if PSYCH_WATERMARKS
		add(psychVersionText);
		ludumVersionText.y -= 30;
		#end

		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		add(versionShit);

		if (menuJSON.fontOutline) {
			versionShit.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			psychVersionText.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			ludumVersionText.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		} else {
			versionShit.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE);
			psychVersionText.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE);
			ludumVersionText.setFormat(Paths.font(menuJSON.font), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE);
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		for (i in 0...menuJSON.objects.length) {
			if (!menuJSON.objectBehindButtons[i]) {
				createObject(i);
			}
		}

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.keys.justPressed.R) {
			//MusicBeatState.switchState(new GameOverSubstateLudum());
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
