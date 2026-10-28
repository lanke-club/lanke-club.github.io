// YouTube blocks (_includes/el/video.html): embed the player directly. Blocks with a cover
// image wait for a click; the rest load right away.
(function () {
  function embed(block, autoplay) {
    if (block.querySelector('iframe')) return;
    var url = block.getAttribute('data-youtube') || '';
    var id = (url.match(/(?:v=|youtu\.be\/|embed\/)([\w-]{11})/) || [])[1];
    if (!id) return;
    var start = (url.match(/[?&]t=(\d+)/) || [])[1];
    var query = [autoplay ? 'autoplay=1' : '', start ? 'start=' + start : ''].filter(Boolean).join('&');
    var frame = document.createElement('iframe');
    frame.src = 'https://www.youtube.com/embed/' + id + (query ? '?' + query : '');
    frame.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
    frame.allowFullscreen = true;
    frame.loading = 'lazy';
    var slot = block.querySelector('.elementor-video');
    if (slot) slot.replaceWith(frame);
    var cover = block.querySelector('.elementor-custom-embed-image-overlay');
    if (cover) cover.remove();
  }
  document.addEventListener('click', function (e) {
    var block = e.target.closest('.lk-video');
    if (block) embed(block, true);
  });
  document.querySelectorAll('.lk-video').forEach(function (block) {
    if (!block.querySelector('.elementor-custom-embed-image-overlay')) embed(block, false);
  });
})();
