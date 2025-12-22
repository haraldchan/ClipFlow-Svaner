Project Structure
```
ClipFlow/
 |──── ClipFlow.ahk
 |──── src/
 |      |──── App.ahk
 |      |──── features/
 |      |      |──── flow-modes/
 |      |      |      └──── flow-modes.ahk
 |      |      |──── clipboard-history/
 |      |      |      |──── clipboard-history.ahk
 |      |      |      |──── clipboard-history-item.ahk
 |      |      |      |──── shared-clips.ahk
 |      |      |      └──── shared-clips-item.ahk
 |      └──── modules/
 |             |──── index.ahk
 |             |──── profile-modify-next/
 |             |      |──── index.ahk
 |             |      |──── components/
 |             |      |      |──── pmn-app.ahk
 |             |      |      |──── guest-profile-details.ahk
 |             |      |      |──── guest-profile-list.ahk
 |             |      |      └──── settings.ahk
 |             |      └──── macros/
 |             |             |──── fill-in.ahk
 |             |             └──── waterfall.ahk
 |             |──── profile-modify-group/
 |             |      |──── index.ahk
 |             |      |──── components/
 |             |      |      |──── pmg-app.ahk
 |             |      |      |──── on-day-groups.ahk
 |             |      |      └──── settings.ahk
 |             |      └──── macros/
 |             |             |──── data-handler.ahk
 |             |             └──── modify-group.ahk
 |             |──── reservation-handler/
 |             |      |──── index.ahk
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
 |                    |──── index.ahk
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
 |      |──── use-dics/
 |      |──── use-json-config.ahk
 |      |──── use-server-agent.ahk
 |      └──── utils.ahk
 └──── clipflow.config.json
```
