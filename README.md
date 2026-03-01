Project Structure
```
ClipFlow/
 |──── ClipFlow.ahk
 |──── src/
 |      |──── App.ahk
 |      |──── features/
 |      |      |──── flow-modes/
 |      |      |      └──── flow-modes.ahk
 |      |      └──── control-center/
 |      |             |──── control-center.ahk
 |      |             |──── clipboard-history/
 |      |             |      |──── clipboard-history.ahk
 |      |             |      |──── clipboard-history-item.ahk
 |      |             |      |──── shared-clips.ahk
 |      |             |      └──── shared-clips-item.ahk
 |      |             └──── listener-hub/
 |      |                    |──── listener-hub.ahk
 |      |                    └──── listener-controller.ahk
 |      └──── modules/
 |             |──── index.ahk
 |             |──── profile-modify-next/
 |             |      |──── profile-modify-next.ahk
 |             |      |──── components/
 |             |      |      |──── pmn-app.ahk
 |             |      |      |──── guest-profile-details.ahk
 |             |      |      |──── guest-profile-list.ahk
 |             |      |      └──── settings.ahk
 |             |      └──── macros/
 |             |             |──── fill-in.ahk
 |             |             └──── waterfall.ahk
 |             |──── profile-modify-group/
 |             |      |──── profile-modify-group.ahk
 |             |      |──── components/
 |             |      |      |──── pmg-app.ahk
 |             |      |      |──── on-day-groups.ahk
 |             |      |      └──── settings.ahk
 |             |      └──── macros/
 |             |             |──── data-handler.ahk
 |             |             └──── modify-group.ahk
 |             |──── reservation-handler/
 |             |      |──── reservation-handler.ahk
 |             |      |──── components/
 |             |      |      |──── rh-app.ahk
 |             |      |      |──── reservation-details.ahk
 |             |      |      |──── reservation-details.ahk
 |             |      |      |──── entry-btns.ahk
 |             |      |      |──── settings.ahk
 |             |      |      |──── settings-ctrip.ahk
 |             |      |      |──── settings-wholesale.ahk
 |             |      |      |──── settings-workflow-ota.ahk
 |             |      |──── data/
 |             |      |      |──── README.txt
 |             |      |      |──── ota-formatter.ahk
 |             |      |      └──── model.ahk
 |             |      └──── macros/
 |             |             |──── fedex-entry.ahk
 |             |             └──── ota-entry.ahk
 |             └──── unified-server-agent/
 |                    |──── unified-server-agent.ahk
 |                    |──── components/
 |                    |      |──── clipboard-listeners.ahk
 |                    |      |──── service-configs.ahk
 |                    |      |──── client-posts.ahk
 |                    |      |──── post-details-profile.ahk
 |                    |      |──── post-details-qm2.ahk
 |                    |      |──── qm2-panel.ahk
 |                    |      └──── modal.ahk
 |                    |──── qm2-modules/
 |                    |      |──── blank-share/
 |                    |      |      |──── blank-share.ahk
 |                    |      |      └──── blank-share-action.ahk
 |                    |      |──── payment-relation/
 |                    |      |      |──── payment-relation.ahk
 |                    |      |      └──── payment-relation-action.ahk
 |                    |      └──── deposit-entry/
 |                    |             └──── deposit-entry.ahk
 |                    └──── server/
 |                           |──── qm-pool/
 |                           |──── pmn-pool/
 |                           |──── test-pool/
 |                           └──── unified-agent.ahk
 |──── assets/
 |──── lib/
 |      |──── index.ahk/
 |      |──── svaner/
 |      |──── system-icon/
 |      |──── use-dict/
 |      |──── use-json-config.ahk
 |      |──── use-server-agent.ahk
 |      └──── utils.ahk
 └──── clipflow.config.json
```
