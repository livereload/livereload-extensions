// Saves options to chrome.storage
function save_options() {
  console.debug('Saving settings...')
  var https = document.getElementById('https').checked;
  var hostname = document.getElementById('hostname').value;
  var port = document.getElementById('port').value;
  chrome.storage.sync.set({
    https: https,
    hostname: hostname,
    port: port
  }, function() {
    // Update status to let user know options were saved.
    var status = document.getElementById('status');
    status.textContent = 'Settings saved. Reconnect Livereload...';
    setTimeout(function() {status.textContent = '';}, 1500);
  });
  return false;
}

// Restores select box and checkbox state using the preferences
// stored in chrome.storage.
function restore_options() {
  document.getElementById('save').addEventListener('click', save_options);
  // Use default value color = 'red' and likesColor = true.
  chrome.storage.sync.get({
    https: 'on',
    hostname: '127.0.0.1',
    port: '35729'
  }, function(items) {
    console.log(items)
    console.debug('Restoring settings...')
    document.getElementById('https').checked = items.https;
    document.getElementById('hostname').value = items.hostname;
    document.getElementById('port').value = items.port;
  });
}
document.addEventListener('DOMContentLoaded', restore_options);
