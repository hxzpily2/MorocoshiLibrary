package net.morocoshi.common.loaders.tfp 
{
	import flash.utils.ByteArray;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	
	/**
	 * TFPLibraryオブジェクト←→AMFデータの相互変換
	 * 
	 * @author tencho
	 */
	public class TFPConverter 
	{
		
		public function TFPConverter() 
		{
		}
		
		/**
		 * TFPLibraryオブジェクトをByteArrayに変換
		 * @param	library	変換するデータ
		 * @param	compress	圧縮するかどうか
		 * @return
		 */
		public function export(library:TFPLibrary, compress:Boolean):ByteArray
		{
			registerClasses();
			library.files.length = 0;
			
			var data:ByteArray = new ByteArray();
			data.writeBoolean(compress);
			var ba:ByteArray = new ByteArray();
			try
			{
				ba.writeObject(library);
				ba.position = 0;
				if(compress) ba.compress();
				data.writeBytes(ba, 0, ba.length);
				data.position = 0;
			}
			catch (e:Error)
			{
				return null;
			}
			return data;
		}
		
		/**
		 * ByteArrayをTFPLibraryオブジェクトに変換
		 * @param	byteArray
		 * @return
		 */
		public function parse(byteArray:ByteArray):TFPLibrary
		{
			registerClasses();
			try
			{
				byteArray.position = 0;
				var uncompress:Boolean = byteArray.readBoolean();
				var ba:ByteArray = new ByteArray();
				byteArray.readBytes(ba);
				if (uncompress) ba.uncompress();
				var library:TFPLibrary = ba.readObject();
				if (library.CLASS_NAME != new TFPLibrary().CLASS_NAME) throw new Error();
			}
			catch (e:Error)
			{
				return null;
			}
			library.files.length = 0;
			library.root.path = library.root.name + "/";
			scanChild(library.root, library, [library.root.name]);
			return library;
		}
		
		private function scanChild(folder:TFPFolder, library:TFPLibrary, dirs:Array):void 
		{
			var path:String = dirs.length? dirs.join("/") + "/" : "";
			for each(var fl:TFPFile in folder.files)
			{
				fl.path = path + fl.name;
				library.files.push(fl);
			}
			for each(var fd:TFPFolder in folder.folders)
			{
				fd.path = path + fd.name + "/";
				library.folders.push(fd);
				scanChild(fd, library, dirs.concat([fd.name]));
			}
		}
		
		public function registerClasses():void
		{
			ClassAliasUtil.register(TFPFile);
			ClassAliasUtil.register(TFPFolder);
			ClassAliasUtil.register(TFPLibrary);
			ClassAliasUtil.register(Vector.<TFPFile>);
			ClassAliasUtil.register(Vector.<TFPFolder>);
		}
		
	}

}