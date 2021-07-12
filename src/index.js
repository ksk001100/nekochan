import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    apiKey: process.env.ELM_APP_CAT_API_KEY
  }
});

document.getElementById("audio-player").volume = 0.1;

app.ports.playAudio.subscribe(function () {
  document.getElementById("audio-player").play();
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
