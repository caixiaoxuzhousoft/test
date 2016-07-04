//
//  QRLocation-Bridging-Header.h
//  QRLocation
//
//  Created by 根岸 裕太 on 2015/10/20.
//  Copyright © 2015年 根岸 裕太. All rights reserved.
//

#ifndef QRLocation_Bridging_Header_h
#define QRLocation_Bridging_Header_h

#import <AFNetworking/AFNetworking.h>
#import "Reachability.h"
#import "SVProgressHUD.h"

#define TIME_OUT 20.0
#define SECURITY_GUARD_MAX_NUMBER 20

//#define STR_REQUEST_URL_AUTH_STAMP          "http://52.69.180.48/auth/stamp"
#define STR_REQUEST_URL_AUTH_STAMP          "http://ec2-52-193-37-4.ap-northeast-1.compute.amazonaws.com/api/auth/stamp"
//#define STR_REQUEST_URL_AUTH_STAMP          "http://asuqa-asq.com/api/auth/stamp"

#define STR_DEFAULT_CODE_HEAD               "ASUQA_"

#define STR_DIALOG_TITLE_CHECK              "確認"
#define STR_DIALOG_TITLE_ERROR              "エラー"
#define STR_DIALOG_TITLE_NUMBER             "ガードマンの人数を入れて下さい"
#define STR_DIALOG_MESSAGE_SEND_SUCCESS     "送信が完了しました。"
#define STR_DIALOG_MESSAGE_SEND_FAILURE     "送信が失敗しました。"
#define STR_DIALOG_MESSAGE_TIMEOUT          "タイムアウトしました。\n再度時間をおいて送信ボタンを押してください。"
#define STR_DIALOG_MESSAGE_NO_NETWORK       "接続状況を確認してください。"
#define STR_DIALOG_MESSAGE_VALIDATE         "半角英数で入力してください。"
#define STR_DIALOG_MESSAGE_NO_CODE          "コードが未入力です。\n入力してください。"
#define STR_DIALOG_MESSAGE_NO_NAME          "氏名が未入力です。\n入力してください。"
#define STR_DIALOG_MESSAGE_NO_BIRTHDAY      "誕生日が未入力です。\n入力をしてください。"
#define STR_DIALOG_MESSAGE_NO_GPS           "位置情報の取得を許可してください。"
#define STR_DIALOG_MESSAGE_NO_CAMERA        "カメラの使用を許可してください。"
#define STR_DIALOG_MESSAGE_NO_GPS_DATA      "位置情報が取得できなかったため、\n位置情報無しで送信します。"
#define STR_TOOLBAR_BUTTON_TITLE            "完了"

#define STR_USERDEFAULTS_KEY_BIRTHDAY       "birthday"

#endif /* QRLocation_Bridging_Header_h */
