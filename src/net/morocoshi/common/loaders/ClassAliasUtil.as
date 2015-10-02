package net.morocoshi.common.loaders 
{
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * クラスエイリアス系処理
	 * 
	 * @author tencho
	 */
	public class ClassAliasUtil
	{
		
		/**
		 * クラスのエイリアスを登録する
		 * @param	obj	クラスオブジェクト
		 */
		static public function register(obj:*):void
		{
			var classObj:Class = obj as Class;
			var aliasName:String = getQualifiedClassName(classObj).split("::").join(".");
			try
			{
				if (getClassByAlias(aliasName) == classObj) {
					return;
				}
			}
			catch (e:Error)
			{
			}
			
			registerClassAlias(aliasName, classObj);
		}
		
		/**
		 * オブジェクトからクラスを特定する
		 * @param	object
		 * @return
		 */
		static public function toClass(object:*):Class
		{
			return getDefinitionByName(getQualifiedClassName(object)) as Class;
		}
		
	}

}