package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

using StringTools;
typedef TitleData =
{

	backgroundSprite:String,
	scrollingBG:Bool,
	scrollPixelsPerSecondX:Float,
	scrollPixelsPerSecondY:Float,
	titleXY:Array<Float>, // titleCentered Required OFF
	titleCenteredAcrossXY:Array<Bool>,
	titleMove:Bool,
	titleSprite:String,
	titleAnimated:Bool, // titleSprite Required ON
	titleAnimation:String, //titleAnimated Required ON
	titleAnimationFrames:Int,
	displayChar:Bool,
	charName:String,
	charAnimation:String,
	charFPS:Int,
	charSize:Float,
	charXY:Array<Float>,
	charCenterAcrossXY:Array<Bool>,
	bpm:Int

}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	public function centerOffChecks(checkX:Bool, checkY:Bool, obj:FlxSprite) {
		if (checkX) obj.screenCenter(X);
		if (checkY) obj.screenCenter(Y);
	}

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if LUA_ALLOWED
		Paths.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				trace('error: $error');
			}

			http.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/titleSettings.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		#end
	}

	var logoBl:FlxSprite;
	var logoBlShadow:FlxSprite;
	var gfDance:FlxSprite;
	var character:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite;
		bg = new FlxSprite(0,0).loadGraphic(Paths.image(titleJSON.backgroundSprite));
		var scrollingBG:FlxBackdrop;
		scrollingBG = new FlxBackdrop(Paths.image(titleJSON.backgroundSprite), XY, 0, 0);
		scrollingBG.velocity.set((titleJSON.scrollPixelsPerSecondX * 100), (titleJSON.scrollPixelsPerSecondY * 100));

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			if (titleJSON.scrollingBG) {
				add(scrollingBG);
			} else {
				add(bg);
			}
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		//add(bg);

		logoBl = new FlxSprite(titleJSON.titleXY[0], titleJSON.titleXY[1]);
		
		if (!titleJSON.titleAnimated) {
			logoBl.loadGraphic(Paths.image(titleJSON.titleSprite));
		} else {
			logoBl.frames = Paths.getSparrowAtlas(titleJSON.titleSprite);
			logoBl.animation.addByPrefix('idle', titleJSON.titleAnimation, titleJSON.titleAnimationFrames);
			logoBl.animation.play('idle');
		}
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.updateHitbox();
		centerOffChecks(titleJSON.titleCenteredAcrossXY[0], titleJSON.titleCenteredAcrossXY[1], logoBl);

		logoBlShadow = new FlxSprite(titleJSON.titleXY[0], titleJSON.titleXY[1]).loadGraphic(Paths.image(titleJSON.titleSprite));

		if (!titleJSON.titleAnimated) {
			logoBlShadow.loadGraphic(Paths.image(titleJSON.titleSprite));
		} else {
			logoBlShadow.frames = Paths.getSparrowAtlas(titleJSON.titleSprite);
			logoBlShadow.animation.addByPrefix('idle', titleJSON.titleAnimation, titleJSON.titleAnimationFrames);
			logoBlShadow.animation.play('idle');
		}

		logoBlShadow.antialiasing = ClientPrefs.globalAntialiasing;
		logoBlShadow.updateHitbox();
		centerOffChecks(titleJSON.titleCenteredAcrossXY[0], titleJSON.titleCenteredAcrossXY[1], logoBlShadow);
		logoBlShadow.color = FlxColor.BLACK;


		var originalY = logoBl.y;
		var shadowOriginalY = logoBlShadow.y;
		
		var logoSpeed = 0.6;

		if (titleJSON.titleMove) {
			FlxTween.tween(logoBl, {y: originalY - 50}, logoSpeed, {
        		ease: FlxEase.quadInOut,
				type: PINGPONG
    		});

			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				FlxTween.tween(logoBlShadow, {y: shadowOriginalY - 50}, logoSpeed, {
        			ease: FlxEase.quadInOut,
					type: PINGPONG
    			});
			});
		}


		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.charXY[0], titleJSON.charXY[1]);
		gfDance.visible = false;

		character = new FlxSprite(titleJSON.charXY[0], titleJSON.charXY[1]);
		character.frames = Paths.getSparrowAtlas(titleJSON.charName);
		character.animation.addByPrefix('idle', titleJSON.charAnimation, titleJSON.charFPS);
		character.animation.play('idle');
		character.visible = titleJSON.displayChar;
		character.setGraphicSize(Std.int(character.width * titleJSON.charSize));
		character.updateHitbox();
		centerOffChecks(titleJSON.charCenterAcrossXY[0], titleJSON.charCenterAcrossXY[1], character);


		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		if(easterEgg == null) easterEgg = ''; //html5 fix

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		//add(gfDance);
		//gfDance.shader = swagShader.shader;
		add(character);
		character.shader = swagShader.shader;
		add(logoBlShadow);
		add(logoBl);
		//for(v in logoBl, logoBlShadow) { v.shader = swagShader.shader }

		//titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		//titleText.visible = false;
		////titleText.screenCenter();
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		//titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else

		//titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			//titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			//titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			//titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			//titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			//titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			//titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		//titleText.antialiasing = ClientPrefs.globalAntialiasing;
		//titleText.animation.play('idle');
		//titleText.updateHitbox();
		//titleText.screenCenter(X);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		if (FlxG.keys.justPressed.R) { 
			FlxTransitionableState.skipNextTransIn = true; 
			FlxTransitionableState.skipNextTransOut = true; 
			MusicBeatState.switchState(new TitleState()); 
		}
		if (FlxG.keys.justPressed.SHIFT) {
			FlxTransitionableState.skipNextTransIn = true; 
			FlxTransitionableState.skipNextTransOut = true; 
			MusicBeatState.switchState(new MainMenuState()); 
		}

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				//titleText.color = FlxColor.interpolate(//titleTextColors[0], //titleTextColors[1], timer);
				//titleText.alpha = FlxMath.lerp(//titleTextAlphas[0], //titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				//titleText.color = FlxColor.WHITE;
				//titleText.alpha = 1;
				

				FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('titleShoot'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(3.42, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		//FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		//FlxG.sound.music.fadeIn(4, 0, 0.7);
		
		function fadeInMusic() {
			//FlxG.sound.music.stop();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					#if SKIP_CREDITS
					fadeInMusic();
					skipIntro();
					#else
					fadeInMusic();
					#end
				case 2:
					#if PSYCH_WATERMARKS
					createCoolText(['Psych Engine by'], 15);
					#else
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					#end
				// credTextShit.visible = true;
				case 4:
					#if PSYCH_WATERMARKS
					addMoreText('Shadow Mario', 15);
					addMoreText('RiverOaken', 15);
					addMoreText('shubs', 15);
					#else
					addMoreText('present');
					#end
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 5:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 6:
					#if PSYCH_WATERMARKS
					createCoolText(['Not associated', 'with'], -40);
					#else
					createCoolText(['In association', 'with'], -40);
					#end
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 10:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 12:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 13:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 14:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 15:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 17:
					skipIntro();
			}
		}

	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			/*if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			} */
			if (playJingle) //Ignore deez
			{
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVER':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHUBS':
						sound = FlxG.sound.play(Paths.sound('JingleShubs'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));

					default: //Go back to normal ugly ass boring GF
						remove(ngSpr);
						remove(credGroup);
						//FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;
						playJingle = false;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(ngSpr);
					remove(credGroup);
					//FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
					};
				}
				playJingle = false;
			}
			else //Default! Edit this one!!
			{
				remove(ngSpr);
				remove(credGroup);
				//FlxG.camera.flash(FlxColor.WHITE, 4);

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
			}
			skippedIntro = true;
		}
	}
}
