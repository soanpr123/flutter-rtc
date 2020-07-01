import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:logindemo/src/style/toast.dart';
import 'package:logindemo/utilities/device_info.dart';
import 'package:socket_io_common_client/socket_io_client.dart' as IO;
import '../socket_client.dart';

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
  IO.Socket _socket = IO.io('https://uoi.bachasoftware.com', {
    'path': '/socket-chat/',
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
  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  OtherEventCallback onEventUpdate;
  JoinRoom _joinRoom;
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

  Signaling(this.token,this._joinRoom);
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

  void invite(int peer_id, String media, use_screen) {
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }
//_getMediatoCall(peer_id, token);
    _createPeerConnection(use_screen).then((pc) {
      peerConnection = pc;
      _createOffer(peer_id, pc, media);
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
_socket.emit('candidate',{
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

  void onMessage(String token){
//    _createPeerConnection(false);
  _socket.on('offer',(data)async{
      var media = 'video';
      var id=data['idFrom'];

      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.CallStateNew);
      }
      var pc = await _createPeerConnection(false);
      peerConnection = pc;
      await pc.setRemoteDescription(new RTCSessionDescription(
          data['sdp']['sdp'], data['sdp']['type']));
      await _createAnswer(id, pc, media,token);
      if (this._remoteCandidates.length > 0) {
        _remoteCandidates.forEach((candidate) async {
          await pc.addCandidate(candidate);
        });
        _remoteCandidates.clear();
      }
  });
  }

  _createAnswer(int id, RTCPeerConnection pc, media,String token) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
print("answer : ${s.type}");
      final description = {
        'sdp': s.sdp,
        'idTo': idTo,
        'token': token,
        'display_name': displayname
      };
_socket.emit('answer',{
  'sdp':{'sdp':s.sdp,'type':s.type}, 'idTo': id, 'token': token
});
    } catch (e) {
      print(e.toString());
    }
  }

  _createOffer(int id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      final description = {
        'sdp': s.sdp,
        'idTo': idTo,
        'token': token,
        'display_name': displayname
      };
//      emitOfferEvent(description);
    } catch (e) {
      print(e.toString());
    }
  }

  hasUserMedia() {
    return navigator.getUserMedia;
  }
  }





enum handlePage { connecting, online, not_online }
