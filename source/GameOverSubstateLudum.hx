package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class GameOverSubstateLudum extends MusicBeatSubstate
{
    public var restartSprite:FlxSprite;
    public var loseSprite:FlxSprite;

    var restartOriginalY:Float;

    var debugTextY:FlxText;
    var debugTextX:FlxText;

    var debugging:Bool = false;

    override function create() 
    {
        super.create();

        restartSprite = new FlxSprite(275, 50).loadGraphic(Paths.image('restart'));
        restartSprite.setGraphicSize(Std.int(restartSprite.width * 0.65));
        restartOriginalY = restartSprite.y;

        FlxTween.tween(restartSprite, { y: restartOriginalY - 50 }, 3, 
            { 
                type:       PINGPONG, 
                ease:       FlxEase.quadInOut, 
                loopDelay:      2 
            }
        );

        FlxG.sound.playMusic(Paths.music('gameOver'));

        add(restartSprite);

        loseSprite = new FlxSprite(100, 100);
        loseSprite.frames = Paths.getSparrowAtlas('lose');
        loseSprite.animation.addByPrefix('idle', 'lose... instance 1', 24, false);
        add(loseSprite);

        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            loseSprite.animation.play('idle');
        });

        // DEBUGGING SHIT

        if (debugging) {
            debugTextY = new FlxText(12, FlxG.height - 44, 0, "Y: " + loseSprite.y, 12);
		    debugTextY.scrollFactor.set();
		    debugTextY.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(debugTextY);

            debugTextX = new FlxText(12, FlxG.height - 24, 0, "X: " + loseSprite.x, 12);
		    debugTextX.scrollFactor.set();
		    debugTextX.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(debugTextX);
        }

        //-----------\\
    }

    override function update(elapsed:Float)
    {
        // DEBUGGING SHIT

        if (debugging) {
            debugTextY.text = "Y: " + loseSprite.y;
            debugTextX.text = "X: " + loseSprite.x;

            if (FlxG.keys.pressed.LEFT) {
                loseSprite.x = loseSprite.x - 1;
            }
            if (FlxG.keys.pressed.RIGHT) {
                loseSprite.x = loseSprite.x + 1;
            }
            if (FlxG.keys.pressed.UP) {
                loseSprite.y = loseSprite.y - 1;
            }
            if (FlxG.keys.pressed.DOWN) {
                loseSprite.y = loseSprite.y + 1;
            } 
        }

        //------------\\

        if (controls.ACCEPT) {
            FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
                    FlxG.sound.music.fadeOut(1, 0);
					MusicBeatState.resetState();
				});
        }

        super.update(elapsed);
    }
}