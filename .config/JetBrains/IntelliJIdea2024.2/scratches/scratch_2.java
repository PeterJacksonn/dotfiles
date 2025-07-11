import com.cse.comms.ArhInfo;
import com.cse.comms.Comms;
import com.cse.comms.ScadaComms;

class Scratch
   {
   public static void main(String[] args)
      {

      String dbAddr = addr != null ? addr : getTagId();
      if((!mSamplingSettings.getIsModifying()) && (dbAddr.toLowerCase().startsWith("b")))
         {
         mSamplingSettings.setSampling("None");
         }
      else
         mSamplingSettings.setSampling("Simple");
      }
   }
// working
private void setSampleIfBoolean(String server, String addr)
   {
   String mServer = server != null ? server : ((ArhInfo)mArchiverList.getSelectedItem()).server;
   String srvType = Comms.getServerType(mServer);
   if (mPrimary && srvType.equalsIgnoreCase(ScadaComms.SRV_TYPE_XARCHIVE))
      {
      String dbAddr = addr != null ? addr : getTagId();
      if((!mSamplingSettings.getIsModifying()) && (dbAddr.toLowerCase().startsWith("b")))
         {
         mSamplingSettings.setSampling("None");
         }
      else
         mSamplingSettings.setSampling("Simple");
      }
   else
      {
      mSamplingSettings.setSampling("Simple");
      }
   }

//working but better
private void setSampleIfBoolean(String server, String addr)
   {
   String mServer = server != null ? server : ((ArhInfo)mArchiverList.getSelectedItem()).server;
   String srvType = Comms.getServerType(mServer);
   String dbAddr = addr != null ? addr : getTagId();
   if ((mPrimary && srvType.equalsIgnoreCase(ScadaComms.SRV_TYPE_XARCHIVE)) && ((!mSamplingSettings.getIsModifying()) && (dbAddr.toLowerCase().startsWith("b"))))
      {
      mSamplingSettings.setSampling("None");
      }
   else
      {
      mSamplingSettings.setSampling("Simple");
      }
   }
