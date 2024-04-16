(import ./ff-userjs.nix) // {
  "media.navigator.enabled" = true;
  "media.getusermedia.audiocapture.enabled" = true;
  "media.getusermedia.screensharing.enabled" = false;
  "media.peerconnection.enabled" = true;
  "webgl.disable-fail-if-major-performance-caveat" = true;
  "webgl.disabled" = true;
  "webgl.enable-webgl2" = true;
  "webgl.min_capability_mode" = true;
}
