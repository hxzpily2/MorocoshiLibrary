package net.morocoshi.air.files
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	
	/**
	 * クリップボード関連
	 * 
	 * @author	tencho
	 */
	public class ClipboardUtil
	{	
		
		/**
		 * ClipboardオブジェクトをClipDataに変換する
		 * @param	dat
		 * @return
		 */
		static public function getClipboard(dat:Clipboard):ClipData
		{
			var clip:ClipData = new ClipData();
			
			var urls:Object = dat.getData(ClipboardFormats.URL_FORMAT);
			var txts:Object = dat.getData(ClipboardFormats.TEXT_FORMAT);
			var files:Object = dat.getData(ClipboardFormats.FILE_LIST_FORMAT);
			var bmps:Object = dat.getData(ClipboardFormats.BITMAP_FORMAT);
			var html:Object = dat.getData(ClipboardFormats.HTML_FORMAT);
			var rtxt:Object = dat.getData(ClipboardFormats.RICH_TEXT_FORMAT);
			if (rtxt) clip.rtf = String(rtxt);
			if (txts as String) clip.text =  String(txts);
			if (urls as String) clip.urlList.push(String(urls));
			if (bmps as BitmapData) clip.bitmapData = bmps as BitmapData;
			//HTMLタグと、その中に含まれる画像パス
			if (html as String)
			{
				clip.html = String(html);
				var m:Array = clip.html.match(/<img\s+.*?>/i);
				if (m)
				{
					m = m[0].match(/<img.*?\s+src\s*=\s*("|')(.*?)("|')/i);
					if (m)
					{
						clip.imagePath = m[2];
					}
				}
			}
			
			//ショートカットファイル
			if (files != null)
			{
				for each(var f:File in files)
				{
					if (!f.isDirectory && f.extension && f.extension.toLowerCase() == "url")
					{
						var data:String = LocalFile.readUTFBytes(f);
						if (data)
						{
							var list:Array = data.match(/^URL=(.*)$/m);
							if (list.length >= 1) clip.urlList.push(String(list[1]));
						}
					}
					else
					{
						clip.fileList.push(f);
					}
				}
			}
			return clip;
		}
		
		/**
		 * クリップボードにテストを設定する
		 * @param	text
		 */
		static public function setText(text:String):void 
		{
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, text);
		}
		
	}
	
}