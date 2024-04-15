package flash.media;

extern final class Microphone extends flash.events.EventDispatcher {
	@:flash.property var activityLevel(get,never) : Float;
	@:flash.property @:require(flash10) var codec(get,set) : SoundCodec;
	@:flash.property @:require(flash10_1) var enableVAD(get,set) : Bool;
	@:flash.property @:require(flash10) var encodeQuality(get,set) : Int;
	@:flash.property @:require(flash10_2) var enhancedOptions(get,set) : MicrophoneEnhancedOptions;
	@:flash.property @:require(flash10) var framesPerPacket(get,set) : Int;
	@:flash.property var gain(get,set) : Float;
	@:flash.property var index(get,never) : Int;
	@:flash.property var muted(get,never) : Bool;
	@:flash.property var name(get,never) : String;
	@:flash.property @:require(flash10_1) var noiseSuppressionLevel(get,set) : Int;
	@:flash.property var rate(get,set) : Int;
	@:flash.property var silenceLevel(get,never) : Float;
	@:flash.property var silenceTimeout(get,never) : Int;
	@:flash.property var soundTransform(get,set) : SoundTransform;
	@:flash.property var useEchoSuppression(get,never) : Bool;
	function new() : Void;
	private function get_activityLevel() : Float;
	private function get_codec() : SoundCodec;
	private function get_enableVAD() : Bool;
	private function get_encodeQuality() : Int;
	private function get_enhancedOptions() : MicrophoneEnhancedOptions;
	private function get_framesPerPacket() : Int;
	private function get_gain() : Float;
	private function get_index() : Int;
	private function get_muted() : Bool;
	private function get_name() : String;
	private function get_noiseSuppressionLevel() : Int;
	private function get_rate() : Int;
	private function get_silenceLevel() : Float;
	private function get_silenceTimeout() : Int;
	private function get_soundTransform() : SoundTransform;
	private function get_useEchoSuppression() : Bool;
	function setLoopBack(state : Bool = true) : Void;
	function setSilenceLevel(silenceLevel : Float, timeout : Int = -1) : Void;
	function setUseEchoSuppression(useEchoSuppression : Bool) : Void;
	private function set_codec(value : SoundCodec) : SoundCodec;
	private function set_enableVAD(value : Bool) : Bool;
	private function set_encodeQuality(value : Int) : Int;
	private function set_enhancedOptions(value : MicrophoneEnhancedOptions) : MicrophoneEnhancedOptions;
	private function set_framesPerPacket(value : Int) : Int;
	private function set_gain(value : Float) : Float;
	private function set_noiseSuppressionLevel(value : Int) : Int;
	private function set_rate(value : Int) : Int;
	private function set_soundTransform(value : SoundTransform) : SoundTransform;
	@:flash.property @:require(flash10_1) static var isSupported(get,never) : Bool;
	@:flash.property static var names(get,never) : Array<Dynamic>;
	@:require(flash10_2) static function getEnhancedMicrophone(index : Int = -1) : Microphone;
	static function getMicrophone(index : Int = -1) : Microphone;
	private static function get_isSupported() : Bool;
	private static function get_names() : Array<Dynamic>;
}
