package net.morocoshi.air.windows 
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.morocoshi.common.math.list.VectorUtil;
	
	/**
	 * モーダルウィンドウっぽい処理（完全じゃない）
	 * 
	 * @author tencho
	 */
	public class ModalManager 
	{
		static private var windowList:Vector.<NativeWindow> = new Vector.<NativeWindow>;
		static private var sprite:Sprite = new Sprite();
		
		public function ModalManager() 
		{
		}
		
		static public function activate(window:NativeWindow):void
		{
			VectorUtil.deleteItem(windowList, window);
			windowList.push(window);
			window.addEventListener(Event.CLOSE, window_closeHandler);
			updateModel();
			window.activate();
		}
		
		static public function remove(window:NativeWindow):void 
		{
			VectorUtil.deleteItem(windowList, window);
			window.removeEventListener(Event.DEACTIVATE, window_deactivateHandler);
			window.removeEventListener(Event.CLOSE, window_closeHandler);
			updateModel();
		}
		
		static private function updateModel():void 
		{
			var n:int = windowList.length - 1;
			for (var i:int = 0; i <= n; i++) 
			{
				var win:NativeWindow = windowList[i];
				if (i == n)
				{
					win.addEventListener(Event.DEACTIVATE, window_deactivateHandler);
				}
				else
				{
					win.removeEventListener(Event.DEACTIVATE, window_deactivateHandler);
				}
				
			}
		}
		
		static private function window_closeHandler(e:Event):void 
		{
			remove(e.currentTarget as NativeWindow);
		}
		
		static private function window_deactivateHandler(e:Event):void 
		{
			if (!NativeApplication.nativeApplication.activeWindow)
			{
				sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				return;
			}
			NativeWindow(e.currentTarget).activate();
		}
		
		/**
		 * Windows7のファイル入力ダイアログを開いた時にフリーズしないようにする処理
		 * @param	e
		 */
		static private function enterFrameHandler(e:Event):void 
		{
			if (NativeApplication.nativeApplication.activeWindow)
			{
				sprite.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				reactivate();
			}
		}
		
		static public function reactivate():void 
		{
			if (!windowList.length) return;
			windowList[windowList.length - 1].activate();
		}
		
	}

}