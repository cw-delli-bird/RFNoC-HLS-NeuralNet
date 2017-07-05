#include "nnet_conv.h"
#include "test_conv1d.h"

//*******************************************************
// Demonstration Weights/Biases
// (hardcoded)
//*******************************************************

weight_t test1_weights[TEST1_N_FILT][TEST1_CHAN] =
          { 1, 1, 1, 1,
            1, 1, 1, 1 };

bias_t   test1_biases[TEST1_CHAN] = { 0.0, 0.1 };

void get_test2(weight_t test2_weights[TEST2_N_FILT][TEST2_CHAN], bias_t test2_biases[TEST2_CHAN]){
  for (int ii=0; ii<TEST2_N_FILT; ii++){
    for (int jj=0; jj<TEST2_CHAN; jj++){
      test2_weights[ii][jj]=1.0;
    }
  }

  for (int ii=0; ii<TEST2_CHAN; ii++) test2_biases[ii]=ii*0.01;
}


//*******************************************************
// Top Level Function
//*******************************************************

void test_conv1d(
      hls::stream<data_t>    &data,
      hls::stream<result_t>  &result)
{
  // Remove ap ctrl ports (ap_start, ap_ready, ap_idle, etc) since we only use the AXI-Stream ports
  #pragma HLS INTERFACE ap_ctrl_none port=return

  // TEST 1
  // nnet::conv_1d<data_t, result_t, weight_t, bias_t, accum_t, TEST1_N_IN, TEST1_CHAN, TEST1_N_FILT>(data, result, test1_weights, test1_biases);

  // TEST 2
  weight_t test2_weights[TEST2_N_FILT][TEST2_CHAN];
  bias_t test2_biases[TEST2_CHAN];
  get_test2(test2_weights, test2_biases);
  nnet::conv_1d<data_t, result_t, weight_t, bias_t, accum_t, TEST2_N_IN, TEST2_CHAN, TEST2_N_FILT>(data, result, test2_weights, test2_biases);
}
