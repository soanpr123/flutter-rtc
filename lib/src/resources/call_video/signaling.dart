import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/webrtc.dart';
import 'package:logindemo/src/style/toast.dart';
import 'package:logindemo/utilities/device_info.dart';

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
  JsonEncoder _encoder = new JsonEncoder();
  JsonDecoder _decoder = new JsonDecoder();
  SimpleWebSocket _socket;
  var _host;
  var _port = 3000;
  RTCPeerConnection peerConnection;
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
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Signaling(this.idTo, this.token, this.displayname);

  Map<String, dynamic> _iceServers = {
    'iceServers': [{
      'urls': ["stun:stun.l.google.com:19302"]
    }, {
      'username': "another_user",
      'credential': "another_password",
      'urls': [
        "turn:117.6.135.148:8579?transport=udp",
        "turn:117.6.135.148:8579?transport=tcp",
      ]
    }
    ]
  };
void JoinCall(int idFrom,String token,String name)async{
  await _getMediaToJoin(idFrom, token, name);
}
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

  void invite(String peer_id, String media, use_screen) {
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peer_id, media, use_screen, isHost: true).then((pc) {
      peerConnection = pc;
      if (media == 'data') {
        _createDataChannel(peer_id, pc);
      }
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
  Future<MediaStream> createStream(media, user_screen) async {
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

  _createPeerConnection(id, media, user_screen, {isHost = false}) async {
    if (media != 'data') _localStream = await createStream(media, user_screen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      final iceCandidate = {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      _socket.socket.emit('candidate', {
        'type': 'candidate',
        'label': candidate.sdpMlineIndex,
        'id': candidate.sdpMid,
        'candidate': candidate.candidate,
        'idTo': id,
        'token':token,
      });
    };

    pc.onIceConnectionState = (state) {
      print('onIceConnectionState $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        bye();
      }
    };

    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }
  void onMessage(tag, message) async {
    switch (tag) {
      case OFFER_EVENT:
        {
          var id = 'caller';
          var description = message;
          var media = 'call';

          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateNew);
          }

          var pc = await _createPeerConnection(id, media, false);
          peerConnection = pc;
          await pc.setRemoteDescription(new RTCSessionDescription(
              description['sdp'], description['type']));
          await _createAnswer(id, pc, media);
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
          var description = message;
          var pc = peerConnection;
          if (pc != null) {
            await pc.setRemoteDescription(new RTCSessionDescription(
                description['sdp'], description['type']));
          }
        }
        break;
      case ICE_CANDIDATE_EVENT:
        {
          var candidateMap = message;
          if (candidateMap != null) {
            var pc = peerConnection;
            RTCIceCandidate candidate = new RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex']);
            if (pc != null) {
              await pc.addCandidate(candidate);
            } else {
              _remoteCandidates.add(candidate);
            }
          }
        }
        break;
      case CLIENT_ID_EVENT:
        {
          if (this.onEventUpdate != null) {
            this.onEventUpdate({'clientId': 'Id: $message'});
          }
        }
        break;
      default:
        break;
    }
  }
  _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);

      final description = {'sdp': s.sdp,'idTo': idTo,'token':token,'display_name':displayname};
      emitAnswerEvent(description);
    } catch (e) {
      print(e.toString());
    }
  }
  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };
    dataChannel = channel;

    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s = await pc
          .createOffer(media == 'data' ? _dc_constraints : _constraints);
      pc.setLocalDescription(s);
      final description = {'sdp': s.sdp, 'idTo': idTo,'token':token,'display_name':displayname};
      emitOfferEvent(description);
    } catch (e) {
      print(e.toString());
    }
  }

  hasUserMedia() {
    return navigator.getUserMedia;
  }
  void connect() async {
    _socket = SimpleWebSocket();
    _socket.onOpen = () {
      print('onOpen');
      this?.onStateChange(SignalingState.ConnectionOpen);
      print({'name': DeviceInfo.label, 'user_agent': DeviceInfo.userAgent});
    };

    _socket.onMessage = (tag, message) {
      print('Received data: $tag - $message');
      this.onMessage(tag, message);
    };

    _socket.onClose = (int code, String reason) {
      print('Closed by server [$code => $reason]!');
      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.ConnectionClosed);
      }
    };
  }
  _getMediaToJoin(int idFrom,String token,String name) async {
    var Stream;
    if (hasUserMedia()) {
      try {
        Stream = await navigator.getUserMedia({
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
        });
      } catch (e) {
        try{
          Stream= await navigator.getUserMedia({'audio':false,'video':false});
        }catch(e){
          Stream=null;
          _socket.socket.emit('refuseCall', { "idTo": idFrom, "token": token, "message": 'Refuse_NotDevice' });
        }
        if(Stream){
          _socket.socket.emit('ready', { 'idTo': idFrom, token: token, 'display_name': name });
        }
      }
    }else{
      ToastShare().getToast("WebRTC is not supported by your devices system version");
      _socket.socket.emit('refuseCall', { "idTo": idFrom, "token": token, "message": 'Refuse_NotDevice' });
    }

  }

  _send(event, data) {
    _socket.send(event, data);
  }
  emitAnswerEvent(description) {
    _send(ANSWER_EVENT, {'description': description});
  }
  emitOfferEvent(description) {
    _send(OFFER_EVENT, {'description': description});
  }
  emitIceCandidateEvent(isHost, candidate) {
    _send(ICE_CANDIDATE_EVENT, {'isHost': isHost, 'candidate': candidate});
  }
}
enum handlePage { connecting, online, not_online }