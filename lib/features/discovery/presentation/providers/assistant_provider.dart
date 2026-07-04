import 'package:flutter/material.dart';
import '../../data/datasources/assistant_api_service.dart';
import '../../data/models/journey_models.dart';

/// One entry in the assistant conversation. User turns carry only text; assistant turns
/// may also carry itineraries (built from the graph on the backend).
class AssistantMessage {
  final bool isUser;
  final String text;
  final List<JourneyItinerary> itineraries;

  const AssistantMessage({
    required this.isUser,
    required this.text,
    this.itineraries = const [],
  });
}

/// Drives the Premium travel-assistant chat. On a 403 it flips [premiumRequired] so the
/// UI can offer an upgrade instead of a raw error.
class AssistantProvider with ChangeNotifier {
  final AssistantApiService apiService;

  AssistantProvider({required this.apiService});

  final List<AssistantMessage> _messages = [];
  bool _isSending = false;
  bool _premiumRequired = false;

  List<AssistantMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get premiumRequired => _premiumRequired;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> send(int userId, String text) async {
    final message = text.trim();
    if (message.isEmpty || _isSending) return;

    _messages.add(AssistantMessage(isUser: true, text: message));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await apiService.ask(userId: userId, message: message);
      _messages.add(AssistantMessage(
        isUser: false,
        text: reply.reply.isEmpty ? 'Listo.' : reply.reply,
        itineraries: reply.itineraries,
      ));
    } on AssistantPremiumRequiredException catch (e) {
      _premiumRequired = true;
      _messages.add(AssistantMessage(isUser: false, text: e.message));
    } catch (e) {
      _messages.add(AssistantMessage(
        isUser: false,
        text: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    _premiumRequired = false;
    notifyListeners();
  }
}
