(import ./ff-userjs.nix) // {
  "dom.webaudio.enabled" = true;
  "media.getusermedia.audiocapture.enabled" = true;
  "media.getusermedia.screensharing.enabled" = false;
  "media.navigator.enabled" = true;
  "media.peerconnection.enabled" = true;
  "webgl.disable-fail-if-major-performance-caveat" = true;
  "webgl.disabled" = true;
  "webgl.enable-webgl2" = true;
  "webgl.min_capability_mode" = true;
}
