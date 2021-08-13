<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterDocument extends Model
{
    protected $table='master_document';
    // public $incrementing = false;

    protected $fillable = [
        'id', 'documents'
    ];
}
