import $ from 'jquery';
import { GloballyPaidSDK} from '@globallypaid/js-sdk';


$(() => {
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
      console.log('Token payload: ', tokenPayload);
      $.ajax({
        type: "POST",
        url: "http://192.168.4.1:4000/payments",
        contentType: "application/json",
        dataType: "json",
        processData: false,
        data: JSON.stringify(tokenPayload),
        // JSON.stringify({          
        //   ccexp: tokenPayload.ExpirationDate,
        //   cvv: tokenPayload.Cvv,
        //   amount: "5",
        //   tokenid: tokenPayload.Token,
        // }),
        success: (response) => {
          if (response.responsecode === "00") {
            console.log('Success', response);
            cardExtended.showSuccess();
          } else {
            cardExtended.showError("Transaction failed");
          }
          console.log(response);
        },
        error: (error) => {
          console.log('Success');
          cardExtended.showSuccess();
        },
      });
    },
    (error) => {
      console.log(error);
      cardExtended.showError("Card mismatch", error);
    }
  ); 
});