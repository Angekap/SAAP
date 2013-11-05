class Repository < ActiveRecord::Base
  validate :name, :url, presence: true
  belongs_to :group
  has_many :students, through: :group

  def update_repo
    if repo_exists?
      begin
        repo.pull
      rescue Git::GitExecuteError
        nil
      end
    else
      false
    end
  end

  def repo
    if repo_exists?
      @repo ||= Git.open(repo_path)
    else
      nil
    end
  end

  def tree(sha1 = 'HEAD')
    repo.gtree(sha1)
  end

  def object(tree_name, path)
    path = split_path(path)
    tree = self.tree(tree_name)
    path.any? ? subtree(tree, path) : tree
  end

  # Repo is initialized without any commits or branchs, even in origin
  def any_commits?
    begin
      repo && repo.log.last
    rescue Git::GitExecuteError
      false
    end
  end

  private

  # navigate through path until lower lvl, then search for blob, and if dont find, search for folder
  def subtree(tree, path)
    if path.size == 1
      tree.blobs[path[0]] || tree.trees[path[0]]
    else
      subtree(tree.trees[path.shift], path)
    end
  end

  def split_path(path)
    path ||= ""
    path.split('/')
  end

  def repo_path
    "tmp/#{name}"
  end

  def repo_exists?
    @repo_exists ||= File.exists? repo_path
  end

end
