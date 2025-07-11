import com.cse.comms.ArhInfo;
import com.cse.comms.ScadaComms;

private void setSampleIfBoolean(server)
   {
   String mServer = server != null ? server : ((ArhInfo)mArchiverList.getSelectedItem()).server;

   if (srvType.equalsIgnoreCase(ScadaComms.SRV_TYPE_XARCHIVE) && !mSamplingSettings.getIsModifying())
      {
      System.out.println("this is some awfulness");
      mSamplingSettings.setSampling("None");
      }
   }