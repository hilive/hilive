package com.hilive.proxysdk;

/**
 * Created by henryye on 2017/11/15.
 */

public class LoadDelegate {
    private static final String TAG = "[hilive][LoadDelegate]";

    public interface ILoadLibrary {
        void loadLibrary(String libName);
        void loadLibrary(String libName, ClassLoader loader);
    }

    private static boolean sLibraryLoaded = false;

    private static ILoadLibrary sInstance = new ILoadLibrary() {
        @Override
        public void loadLibrary(String libName) {
            loadSo(libName);
        }

        @Override
        public void loadLibrary(String libName, ClassLoader loader) {
        }

        private boolean loadSo(String libName)
        {
            final int kMaxTry = 3;
            for (int i = 0; i < kMaxTry; ++ i)
            {
                try
                {
                    System.loadLibrary(libName);
                    LogDelegate.i(TAG, "loadSo " + libName + " success!");
                    return true;
                }
                catch (UnsatisfiedLinkError e)
                {
                    String err = (e.getMessage() == null) ? "null" : e.getMessage();
                    LogDelegate.e(TAG, "loadSo " + libName + " failed UnsatisfiedLinkError " + err);
                }
                catch (SecurityException e)
                {
                    String err = (e.getMessage() == null) ? "null" : e.getMessage();
                    LogDelegate.e(TAG, "loadSo " + libName + " failed SecurityException " + err);
                }
                catch (NullPointerException e)
                {
                    String err = (e.getMessage() == null) ? "null" : e.getMessage();
                    LogDelegate.e(TAG, "loadSo " + libName + " failed NullPointerException " + err);
                }
                catch (Throwable e)
                {
                    LogDelegate.printStackTrace(TAG, e, "loadSo");
                }
            }

            return false;
        }
    };

    public static void setInstance(ILoadLibrary instance) {
        if(instance != null) {
            sInstance = instance;
        }
    }

    public static void loadLibrary(String name) {
        sInstance.loadLibrary(name);
    }

    public static void loadLibrary(String name, ClassLoader loader) {
        sInstance.loadLibrary(name, loader);
    }
}
