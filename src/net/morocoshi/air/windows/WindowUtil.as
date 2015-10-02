package net.morocoshi.air.windows 
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.system.Capabilities;
	
	/**
	 * Airウィンドウ系処理
	 * 
	 * @author tencho
	 */
	public class WindowUtil 
	{
		/**
		 * ウィンドウの位置を画面内に収まるように調整する。
		 * @param	win
		 */
		static public function adjustPosition(win:NativeWindow):void
		{
			if (win.x + win.width > Capabilities.screenResolutionX)
			{
				win.x = Capabilities.screenResolutionX - win.width;
			}
			if (win.y > Capabilities.screenResolutionY - 5)
			{
				win.y = Capabilities.screenResolutionY - 5;
			}
			if (win.x < 0) win.x = 0;
			if (win.y < 0) win.y = 0;
		}
		/**
		 * ウィンドウを画面の中央に移動する
		 * @param	win	移動するウィンドウ
		 * @param	adjust	ウィンドウが画面外にいかないようにする
		 */
		static public function moveCenter(win:NativeWindow, adjust:Boolean = true):void
		{
			win.x = (Capabilities.screenResolutionX - win.width) * 0.5;
			win.y = (Capabilities.screenResolutionY - win.height) * 0.5;
			if (adjust) adjustPosition(win);
		}
		
		/**
		 * ウィンドウオプション用クラスを生成
		 * @param	owner			この NativeWindowInitOptions で作成されたすべてのウィンドウを所有する NativeWindow オブジェクトを指定します。ウィンドウに所有者がある場合、そのウィンドウは常に所有者の前面に表示されます。所有者が最小化、非表示の場合や閉じる場合にも同様に処理されます。
		 * @param	maximizable		ユーザーがウィンドウを最大化できるかどうかを指定します。
		 * @param	minimizable		ユーザーがウィンドウを最小化できるかどうかを指定します。
		 * @param	resizable		ユーザーがウィンドウのサイズを変更できるかどうかを指定します。
		 * @param	transparent		ウィンドウが、デスクトップに対する透明度とアルファの組み合わせをサポートするかどうかを指定します。
		 * @param	type			作成するウィンドウのタイプを指定します。このプロパティの有効な値の定数は、NativeWindowType クラスで定義されます。
		 * @param	systemChrome	ウィンドウでシステムクロムを使用するかどうかを指定します。このプロパティの有効な値の定数は、NativeWindowSystemChrome クラスで定義されます。
		 * @return
		 */
		static public function createOption(owner:NativeWindow = null, maximizable:Boolean = true, minimizable:Boolean = true, resizable:Boolean = true, type:String = NativeWindowType.NORMAL, systemChrome:String = NativeWindowSystemChrome.STANDARD, transparent:Boolean = false):NativeWindowInitOptions 
		{
			var opt:NativeWindowInitOptions = new NativeWindowInitOptions();
			opt.maximizable = maximizable;
			opt.minimizable = minimizable;
			opt.owner = owner;
			opt.resizable = resizable;
			opt.transparent = transparent;
			opt.type = type || NativeWindowType.NORMAL;
			opt.systemChrome = systemChrome || NativeWindowSystemChrome.STANDARD;
			return opt;
		}
		
	}

}