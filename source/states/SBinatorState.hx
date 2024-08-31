package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import objects.Bar;
import states.TitleState;

class SBinatorState extends MusicBeatState
{
    var mainBackground:FlxSprite;
    var mainChecker:FlxBackdrop;
    var mainLogo:FlxSprite;
    var mainText:FlxText;
    var mainLoaderSpin:FlxSprite;
	var mainLoadingBar:Bar;
	var skipText:FlxText;
	var keybindActivation:Bool = false;
	var icons:FlxSprite;
	var creditTexts:FlxText;
    var tweening:Bool;
    var timer:Float = 0;
    var string:String = '';
	var loadingTime:Float = 0;
	public static var sillyIcons:Array<String> = ['stefan', 'hutaroz', 'plus', 'mays', 'fearester'];
	public static var sillyTexts:Array<String> = ['Stefan2008', 'Hutaro', 'IsThePlusOpd', 'MaysLastPlay', 'Fearester2008'];

    override function create()
    {
		Main.tweenFPS();
		FlxG.sound.playMusic(Paths.music('engineStuff/title/loadingMusic'), 1); // Credits: Roblox Corporation
		FlxG.mouse.visible = false;
        super.create();

        #if DISCORD_ALLOWED
	    // Updating Discord Rich Presence
	    DiscordClient.changePresence("Loading SB Engine...", null);
	    #end

        mainBackground = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		mainBackground.antialiasing = ClientPrefs.data.antialiasing;
        mainBackground.screenCenter();
        mainBackground.color = FlxColor.BROWN;
		add(mainBackground);

        mainChecker = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x70000000, 0x0));
		mainChecker.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		mainChecker.visible = ClientPrefs.data.checkerboard;
		mainChecker.screenCenter();
		add(mainChecker);

        mainLogo = new FlxSprite().loadGraphic(Paths.image("engineStuff/main/sbEngineLogo"));
		mainLogo.screenCenter();
		mainLogo.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.angle(mainLogo, mainLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
        new FlxTimer().start(2, function(tmr:FlxTimer) {
			if (mainLogo.angle == -10)
				FlxTween.angle(mainLogo, mainLogo.angle, 10, 2, {ease: FlxEase.sineInOut});
			else
				FlxTween.angle(mainLogo, mainLogo.angle, -10, 2, {ease: FlxEase.sineInOut});
		}, 0);
		add(mainLogo);

		mainLoadingBar = new Bar(0, FlxG.height * 0.94, 'healthBar', function() return loadingTime, 0, 15);
		mainLoadingBar.screenCenter(X);
		mainLoadingBar.leftBar.color = FlxColor.BROWN;
		mainLoadingBar.rightBar.color = 0xFF1A1A1A;
		add(mainLoadingBar);

        mainText = new FlxText(1120, FlxG.height - 50, 0, "Loading...", 8);
		mainText.scrollFactor.set();
		mainText.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		mainText.borderSize = 1.25;
		add(mainText);

        mainLoaderSpin = new FlxSprite().loadGraphic(Paths.image("engineStuff/main/loadingSpeen"));
		mainLoaderSpin.screenCenter(X);
		mainLoaderSpin.setGraphicSize(Std.int(mainLoaderSpin.width * 0.89));
		mainLoaderSpin.x = FlxG.width - 130;
		mainLoaderSpin.y = FlxG.height - 130;
		mainLoaderSpin.angularVelocity = 180;
		mainLoaderSpin.antialiasing = ClientPrefs.data.antialiasing;
		add(mainLoaderSpin);

		skipText = new FlxText(20, FlxG.height - #if mobile 80 #else 110 #end, 1000, #if mobile "Got annoyed waiting? Tap on screen to skip loading screen" #else "Got annoyed waiting? Press SPACE to skip loading screen" #end, 10);
		skipText.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.alpha = 0;
		new FlxTimer().start(5, function(tmr:FlxTimer) {
			FlxTween.tween(skipText, {alpha: 1}, 1.5, {
				ease: FlxEase.sineInOut,
				onComplete: function(completition:FlxTween) {
					keybindActivation = true;
				}
			});
		});
		skipText.screenCenter(X);
		add(skipText);

		icons = new FlxSprite(40, FlxG.height * 0.78).loadGraphic(randomCreditIcons());
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.setGraphicSize(Std.int(icons.width * 0.89));
		add(icons);

		creditTexts = new FlxText(30, FlxG.height * 0.95, "");
		creditTexts.scrollFactor.set();
		creditTexts.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		randomCreditText();
		add(creditTexts);

        super.create();
    }

	var screenJustPressed:Bool = false;
    override function update(elapsed:Float) 
    {
		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				screenJustPressed = true;
			}
		}
		#end

		loadingTime += elapsed;
		if (loadingTime >= 15) {
			updateBarPercent();
			mainText.text = "Done!";
			mainText.x = 1155;
			skipText.visible = false;
		}

		// Got annoyed waiting to fully finish the "fake" loading screen?
		if (FlxG.keys.justPressed.SPACE #if mobile || screenJustPressed #end && keybindActivation) {
			switchToTitleMenu();
			mainText.text = "Skipped!";
			mainText.x = 1135;
		}

        super.update(elapsed);
    }

	public var barTween:FlxTween = null;
	var val1:Float = 1;
	var val2:Float = 15;
	function updateBarPercent() {
		barTween = FlxTween.tween(mainLoadingBar, {percent: (val1 / val2) * 100}, 0.5, {ease: FlxEase.sineInOut,
			onComplete: function(twn:FlxTween) switchToTitleMenu(),
			onUpdate: function(twn:FlxTween) mainLoadingBar.updateBar()
		});
	}

	function switchToTitleMenu() {
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Done! Booting the engine...", null);
		#end
		FlxG.camera.fade(FlxColor.BLACK, 0.40, false, function() {
			MusicBeatState.switchState(new TitleState());
		});
	}

	public function randomCreditIcons()
	{
		var iconChance:Int = FlxG.random.int(0, sillyIcons.length - 1);
		return Paths.image('credits/${sillyIcons[iconChance]}');
	}

	public function randomCreditText()
	{
		var textChance:Int = FlxG.random.int(0, sillyTexts.length - 1);
		return creditTexts.text = sillyTexts[textChance];
	}
}
