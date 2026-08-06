const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

/**
 * Спрацьовує при створенні документа в `notifications` (з діалогу
 * створення сповіщення в Command Center) і надсилає реальний FCM push.
 *
 * УВАГА: вимагає план Blaze (pay-as-you-go) — Cloud Functions не
 * деплояться на Spark в принципі, незалежно від покоління. Безкоштовна
 * квота (2M викликів/міс, 5GB egress) з запасом покриє воркфорс-застосунок
 * такого масштабу.
 *
 * broadcast/team надсилаються через FCM-теми (див.
 * push_notification_service.dart для відповідної підписки на клієнті),
 * тому ця функція не читає users для цих випадків. individual —
 * напряму по збережених users/{uid}.fcmTokens.
 */
exports.sendNotificationPush = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { title, body, audienceType, targetTeamId, targetUserId } = data;

    const payload = {
      notification: { title, body },
      data: { notificationId: context.params.notificationId },
    };

    try {
      if (audienceType === 'broadcast') {
        await admin.messaging().send({ topic: 'all_heroes', ...payload });
        return;
      }

      if (audienceType === 'team' && targetTeamId) {
        await admin.messaging().send({ topic: `team_${targetTeamId}`, ...payload });
        return;
      }

      if (audienceType === 'individual' && targetUserId) {
        const userDoc = await admin
          .firestore()
          .collection('users')
          .doc(targetUserId)
          .get();
        const tokens = userDoc.data()?.fcmTokens || [];
        if (tokens.length === 0) return;

        const response = await admin.messaging().sendEachForMulticast({
          tokens,
          ...payload,
        });

        // Прибираємо токени, які більше не валідні (видалений застосунок і т.п.)
        const staleTokens = [];
        response.responses.forEach((r, i) => {
          if (!r.success && r.error?.code === 'messaging/registration-token-not-registered') {
            staleTokens.push(tokens[i]);
          }
        });
        if (staleTokens.length > 0) {
          await admin
            .firestore()
            .collection('users')
            .doc(targetUserId)
            .update({
              fcmTokens: admin.firestore.FieldValue.arrayRemove(...staleTokens),
            });
        }
      }
    } catch (err) {
      console.error('sendNotificationPush failed:', err);
    }
  });
