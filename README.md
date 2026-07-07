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
 |             |      |      └──── db-selector.ahk
 |             |      |──── schema/
 |             |      |      |──── guest-profile.ahk
 |             |      |      └──── ws-message-formatter.ahk
 |             |      └──── macros/
 |             |             |──── fill-in.ahk
 |             |             |──── fill-psb.ahk
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
 |             |──── unified-server-agent/
 |             |      |──── unified-server-agent.ahk
 |             |      |──── components/
 |             |      |      |──── service-configs.ahk
 |             |      |      |──── client-posts.ahk
 |             |      |      |──── post-details-profile.ahk
 |             |      |      |──── post-details-qm2.ahk
 |             |      |      |──── qm2-panel.ahk
 |             |      |      └──── modal.ahk
 |             |      └──── server/
 |             |             └──── unified-agent.ahk
 |             └──── qm2-modules/
 |                           |──── blank-share/
 |                           |      |──── blank-share.ahk
 |                           |      └──── blank-share-action.ahk
 |                           |──── payment-relation/
 |                           |      |──── payment-relation.ahk
 |                           |      └──── payment-relation-action.ahk
 |                           └──── transaction-entry/
 |                                  └──── transaction-entry.ahk
 |                                  └──── transaction-entry-action.ahk
 |──── assets/
 |──── lib/
 |      |──── index.ahk
 |      |──── svaner/
 |      |──── system-icon/
 |      |──── use-dict/
 |      |──── use-json-config.ahk
 |      |──── use-server-agent.ahk
 |      └──── utils.ahk
 |──── ws-reader
 |      |──── assets/
 |      |──── dicts/ (dictionaries)
 |      |──── js/    (components & helpers)
 |      |──── ws-reader.css
 |      |──── ws-reader.html
 |      └──── ws-reader.js
 └──── clipflow.config.json
```
