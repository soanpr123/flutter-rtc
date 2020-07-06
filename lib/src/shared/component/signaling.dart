import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:logindemo/src/shared/component/connfig.dart';
import 'package:logindemo/src/shared/component/socket_client.dart';


import 'package:socket_io_common_client/socket_io_client.dart' as IO;

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * callbacks for Signaling API.
 */
typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
  IO.Socket _socket = IO.io(Config.REACT_APP_URL_SOCKETIO, {
//    'path': '/socket-chat/',
    'transports': ['polling'],
  });
  RTCPeerConnection peerConnection;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  RTCDataChannel dataChannel;
  var _remoteCandidates = [];
  var _turnCredential;
  int idTo;
  String token;
  String displayname;
  JoinRoom _joinRoom;
  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  OtherEventCallback onEventUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;
  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {
        'urls': ["stun:stun.l.google.com:19302"]
      },
      {
        'username': "another_user",
        'credential': "another_password",
        'urls': [
          "turn:117.6.135.148:8579?transport=udp",
          "turn:117.6.135.148:8579?transport=tcp",
        ]
      }
    ]
  };

  Signaling(this.token);
  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dc_constraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (peerConnection != null) {
      peerConnection.close();
    }
//    if (_socket != null) _socket.close();
  }

  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void invite(int peer_id, String media, use_screen,String name) {
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }
    _socket.emit('invitCall', {'idFriend': peer_id, 'token': token});
    _socket.on('ready', (data){
      _createPeerConnection(false).then((pc) {
            peerConnection = pc;
            _createOffer(data['idFrom'], pc, 'video', token,name);
          });
    });
  }

  void bye() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (dataChannel != null) {
      dataChannel.close();
    }
    if (peerConnection != null) {
      peerConnection.close();
    }

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateBye);
    }
    _remoteCandidates.clear();
  }

  Future<MediaStream> createStream(user_screen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = user_screen
        ? await navigator.getDisplayMedia(mediaConstraints)
        : await navigator.getUserMedia(mediaConstraints);
    if (this.onLocalStream != null) {
      this.onLocalStream(stream);
    }
    return stream;
  }

  _createPeerConnection(user_screen) async {
    _localStream = await createStream(user_screen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      _socket.emit('candidate', {
        'type': 'candidate',
        'label': candidate.sdpMlineIndex,
        'id': candidate.sdpMid,
        'candidate': candidate.candidate,
        'idTo': 580,
        'token': token
      });
    };
    pc.onIceConnectionState = (state) {};
    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
//      _remoteStreams.add(stream);
    };
    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };
    return pc;
  }

  void onMessage(tag, data) async {
    switch (tag) {
      case OFFER_EVENT:
        {
          print("Data là :$data");
          var media = 'video';
          var id = data['idFrom'];
          print("id là : $id");
          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateNew);
          }
          var pc = await _createPeerConnection(false);
          peerConnection = pc;
          await pc.setRemoteDescription(new RTCSessionDescription(
              data['sdp']['sdp'], data['sdp']['type']));
          await _createAnswer(id, pc, media, token);
          if (this._remoteCandidates.length > 0) {
            _remoteCandidates.forEach((candidate) async {
              await pc.addCandidate(candidate);
            });
            _remoteCandidates.clear();
          }
        }
        break;
      case ANSWER_EVENT:
        {
          print("answer là : $data");
          _socket.emit(
              'join_call_room', {'callRoom': data['callRoom'], 'token': token});
          var pc = peerConnection;
          if (pc != null) {
            await pc.setRemoteDescription(new RTCSessionDescription(
                data['sdp']['sdp'], data['sdp']['type']));
          }
        }
        break;
//      case READY_EVENT:
//        {
//          print("ready là : $data");
//          _createPeerConnection(false).then((pc) {
//            peerConnection = pc;
//            _createOffer(data['idFrom'], pc, 'video', token);
//          });
//        }
//        break;
    }
  }

  void connect() {
    _joinRoom = JoinRoom();
    _joinRoom.offerEvent();
    _joinRoom.answerEvent();
    _joinRoom.readyrEvent();
    _joinRoom.onMessage = (tag, message) {
      print('Received data: $tag - $message');
      this.onMessage(tag, message);
    };
  }

  _createAnswer(int id, RTCPeerConnection pc, media, String token) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      print("answer : ${s.type}");
      _socket.emit('answer', {
        'sdp': {'sdp': s.sdp, 'type': s.type},
        'idTo': id,
        'token': token
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _createOffer(int id, RTCPeerConnection pc, String media, String token,String name) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      _socket.emit('offer', {
        'sdp': {'sdp': s.sdp, 'type': s.type},
        'idTo': id,
        'token': token,
        'display_name': name,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  hasUserMedia() {
    return navigator.getUserMedia;
  }
}

enum handlePage { connecting, online, not_online }
