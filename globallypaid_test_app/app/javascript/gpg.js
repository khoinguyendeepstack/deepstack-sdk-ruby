import { GloballyPaidSDK} from '@globallypaid/js-sdk';

window.GloballyPaidSDK = GloballyPaidSDK;

const gpg = new GloballyPaidSDK("pk_test_pr9IokgZOcNd0YGLuW3unrvYvLoIkCCk");

const cardExtended = gpg.createForm("card-extended", {
  style: {
    base: {
      width: "560px",
    },
  },
});

cardExtended.mount("gpg-form");

cardExtended.on(
  "TOKEN_CREATION",
  (tokenPayload) => {
    $.ajax({
      type: "POST",
      url: "https://qa.gpgv1-api.gpgway.com/api/charge",
      contentType: "application/json",
      dataType: "json",
      processData: false,
      data: JSON.stringify({
        tokenid: tokenPayload.Token,
        ccexp: tokenPayload.ExpirationDate,
        cvv: tokenPayload.Cvv,
        amount: "0.05",
      }),
      success: (response) => {
        if (response.responsecode === "00") {
          console.log('Success');
          cardExtended.showSuccess();
        } else {
          cardExtended.showError("Transaction failed");
        }
        console.log(response);
      },
      error: (error) => {
        cardExtended.showError("Server was not reached");
      },
    });
  },
  (error) => {
    console.log(error);
    cardExtended.showError("Card mismatch");
  }
);