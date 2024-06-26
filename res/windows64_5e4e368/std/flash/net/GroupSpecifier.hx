package flash.net;

@:require(flash10_1) extern class GroupSpecifier {
	@:flash.property var ipMulticastMemberUpdatesEnabled(get,set) : Bool;
	@:flash.property var minGroupspecVersion(get,set) : Int;
	@:flash.property var multicastEnabled(get,set) : Bool;
	@:flash.property var objectReplicationEnabled(get,set) : Bool;
	@:flash.property var peerToPeerDisabled(get,set) : Bool;
	@:flash.property var postingEnabled(get,set) : Bool;
	@:flash.property var routingEnabled(get,set) : Bool;
	@:flash.property var serverChannelEnabled(get,set) : Bool;
	function new(name : String) : Void;
	function addBootstrapPeer(peerID : String) : Void;
	function addIPMulticastAddress(address : String, ?port : Dynamic, ?source : String) : Void;
	function authorizations() : String;
	private function get_ipMulticastMemberUpdatesEnabled() : Bool;
	private function get_minGroupspecVersion() : Int;
	private function get_multicastEnabled() : Bool;
	private function get_objectReplicationEnabled() : Bool;
	private function get_peerToPeerDisabled() : Bool;
	private function get_postingEnabled() : Bool;
	private function get_routingEnabled() : Bool;
	private function get_serverChannelEnabled() : Bool;
	function groupspecWithAuthorizations() : String;
	function groupspecWithoutAuthorizations() : String;
	function makeUnique() : Void;
	function setPostingPassword(?password : String, ?salt : String) : Void;
	function setPublishPassword(?password : String, ?salt : String) : Void;
	private function set_ipMulticastMemberUpdatesEnabled(value : Bool) : Bool;
	private function set_minGroupspecVersion(value : Int) : Int;
	private function set_multicastEnabled(value : Bool) : Bool;
	private function set_objectReplicationEnabled(value : Bool) : Bool;
	private function set_peerToPeerDisabled(value : Bool) : Bool;
	private function set_postingEnabled(value : Bool) : Bool;
	private function set_routingEnabled(value : Bool) : Bool;
	private function set_serverChannelEnabled(value : Bool) : Bool;
	function toString() : String;
	@:flash.property static var maxSupportedGroupspecVersion(get,never) : Int;
	static function encodeBootstrapPeerIDSpec(peerID : String) : String;
	static function encodeIPMulticastAddressSpec(address : String, ?port : Dynamic, ?source : String) : String;
	static function encodePostingAuthorization(password : String) : String;
	static function encodePublishAuthorization(password : String) : String;
	private static function get_maxSupportedGroupspecVersion() : Int;
}
