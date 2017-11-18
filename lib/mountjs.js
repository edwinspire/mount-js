"use strict";
const execFile = require('child_process').execFile;
const spawn = require('child_process').spawn;
const fs = require('fs');
var EventEmitter   = require('events').EventEmitter;

var MountJS = EventEmitter;
MountJS.prototype.parameters = {domain: '', username: '', password: '', location: '', protocol: 'smb', timeout: 60, anonymous: true};

MountJS.prototype.mount = function (_param) {
  var t = this;
var args = [];

  if(_param){
    this.parameters = _param;
  }

args.push(this.parameters.protocol);
args.push(this.parameters.domain);
args.push(this.parameters.location);
args.push(this.parameters.anonymous);
args.push(this.parameters.username);
args.push(this.parameters.password);
args.push(this.parameters.timeout);

  const child = spawn('mount', args);
  child.on('close', (code, signal) => {
    console.log(
      `child process terminated due to receipt of signal ${signal}`);
  });

  child.on('exit', (code, signal) => {

    switch(code){
      case 0:
      t.emit('mounted', {location: args[0], code: code});
      break;
      case 2:
      t.emit('fail', {message: 'Ya se encuentra montado', location: args[0], code: code});
      break;
    }

    console.log(
      `child process exit ${code}`,  code, signal);
  });

  child.on('error', (error) => {
    console.log(
      `child process error ${error}`);
  });


  child.on('message', (message) => {
    console.log(
      `child process message due to receipt of message ${message}`);
  });

  child.stdout.on('data', (message) => {
    console.log(message+'');

    if((new RegExp('Password:')).test(message)){
      console.log(t.parameters.password);
      if(i < 3){
        child.stdin.write(t.parameters.password);
        child.stdin.write('\n');
      }else{
        child.kill();
        t.emit('fail', {message: 'La contraseña no es correcta', error: -1, location: args[0]});
      }
    }
    
    i++;
  });

  child.stderr.on('data', function (data) {
    console.log('stderr: ' + data);
    t.emit('fail', {message: data+'', error: -2, location: args[0]});
  });


}

module.exports = MountJS;